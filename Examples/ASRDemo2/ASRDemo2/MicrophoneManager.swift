
import Foundation
import AVFoundation
import Combine

class MicrophoneManager: ObservableObject {
    @Published var isRecording = false
    @Published var errorMessage: String?

    private var audioEngine: AVAudioEngine?
    private var audioInputNode: AVAudioInputNode?
    private var audioStreamContinuation: AsyncStream<Data>.Continuation?
    private var audioStream: AsyncStream<Data>?

    // Public AsyncStream for audio data
    var sharedAudioStream: AsyncStream<Data> {
        if let stream = audioStream {
            return stream
        } else {
            let (stream, continuation) = AsyncStream.makeStream(of: Data.self)
            self.audioStream = stream
            self.audioStreamContinuation = continuation
            return stream
        }
    }

    private var audioConverter: AVAudioConverter? // Declare converter here

    init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: [.duckOthers, .mixWithOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to set up audio session: \(error.localizedDescription)"
            }
            print("Error setting up audio session: \(error.localizedDescription)")
        }
    }

    func startRecording() async {
        guard !isRecording else { return }

        // Request microphone permission if not already granted
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        if status == .notDetermined {
            await AVCaptureDevice.requestAccess(for: .audio)
        }

        guard AVCaptureDevice.authorizationStatus(for: .audio) == .authorized else {
            DispatchQueue.main.async {
                self.errorMessage = "Microphone permission not granted."
            }
            print("Microphone permission not granted.")
            return
        }

        audioEngine = AVAudioEngine()
        audioInputNode = audioEngine?.inputNode

        guard let audioEngine = audioEngine, let audioInputNode = audioInputNode else {
            DispatchQueue.main.async {
                self.errorMessage = "Audio engine or input node not available."
            }
            return
        }

        let inputFormat = audioInputNode.outputFormat(forBus: 0)
        // Desired output format for ASR (16kHz, 16-bit PCM, mono)
        var outputAudioDescription = AudioStreamBasicDescription(
            mSampleRate: 16000,
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked,
            mBytesPerPacket: 2, // 16-bit = 2 bytes
            mFramesPerPacket: 1,
            mBytesPerFrame: 2, // 16-bit = 2 bytes
            mChannelsPerFrame: 1,
            mBitsPerChannel: 16,
            mReserved: 0
        )
        guard let outputFormat = AVAudioFormat(streamDescription: &outputAudioDescription) else {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to create output audio format."
            }
            return
        }

        print("Microphone input format: \(inputFormat)")
        print("Desired output format: \(outputFormat)")

        // Create the audio converter once
        self.audioConverter = AVAudioConverter(from: inputFormat, to: outputFormat)
        if self.audioConverter == nil {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to create audio converter. Input: \(inputFormat), Output: \(outputFormat)"
            }
            return
        }

        // Explicitly set sample rate converter quality
        self.audioConverter?.sampleRateConverterQuality = AVAudioQuality.high.rawValue

        // Install a tap on the input node to capture audio
        audioInputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] (buffer, time) in
            guard let self = self, let converter = self.audioConverter else { return }

            let pcmBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: AVAudioFrameCount(buffer.frameLength))!

            var error: NSError? = nil

            let inputBlock: AVAudioConverterInputBlock = { inNumPackets, outStatus in
                outStatus.pointee = .haveData
                return buffer
            }

            converter.convert(to: pcmBuffer, error: &error, withInputFrom: inputBlock)

            if let error = error {
                print("Error during conversion: \(error.localizedDescription)")
                return
            }

            // Convert AVAudioPCMBuffer to Data
            let channelData = pcmBuffer.int16ChannelData![0]
            let frameLength = Int(pcmBuffer.frameLength)
            let data = Data(bytes: channelData, count: frameLength * MemoryLayout<Int16>.size)

            // Yield the audio data to the AsyncStream
            self.audioStreamContinuation?.yield(data)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
            isRecording = true
            DispatchQueue.main.async {
                self.errorMessage = nil
            }
            print("Microphone recording started.")
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to start audio engine: \(error.localizedDescription)"
            }
            print("Error starting audio engine: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        guard isRecording else { return }

        audioEngine?.stop()
        audioInputNode?.removeTap(onBus: 0)
        audioEngine = nil
        audioInputNode = nil
        isRecording = false
        audioStreamContinuation?.finish() // Signal that the stream is complete
        audioStreamContinuation = nil
        audioStream = nil
        audioConverter = nil // Clear the converter when stopping
        print("Microphone recording stopped.")
    }

    func pauseRecording() {
        guard isRecording else { return }
        audioEngine?.pause()
        isRecording = false
        print("Microphone recording paused.")
    }

    func resumeRecording() {
        guard !isRecording else { return }
        do {
            try audioEngine?.start()
            isRecording = true
            print("Microphone recording resumed.")
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to resume audio engine: \(error.localizedDescription)"
            }
            print("Error resuming audio engine: \(error.localizedDescription)")
        }
    }
}
