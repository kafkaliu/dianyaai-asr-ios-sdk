import AVFoundation
import Combine
import Foundation
import OSLog

class MicrophoneManager: ObservableObject {
    private static let subsystem = "com.dianyaai.DianyaaiASR.Examples.ASRDemo2"
    private static let `default` = os.Logger(subsystem: subsystem, category: "MicrophoneManager")
    @Published var isRecording = false
    @Published var errorMessage: String?

    private var audioEngine: AVAudioEngine?
    private var audioInputNode: AVAudioInputNode?
    private var audioStreamContinuation: AsyncStream<Data>.Continuation?
    private var audioStream: AsyncStream<Data>?
    private var pcmData: Data?

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

    private var audioConverter: AVAudioConverter?  // Declare converter here

    init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(
                .record, mode: .measurement, options: [.duckOthers, .mixWithOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to set up audio session: \(error.localizedDescription)"
            }
            Self.default.error("Error setting up audio session: \(error.localizedDescription)")
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
            Self.default.warning("Microphone permission not granted.")
            return
        }

        audioEngine = AVAudioEngine()
        audioInputNode = audioEngine?.inputNode
        pcmData = Data()

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
            mBytesPerPacket: 2,  // 16-bit = 2 bytes
            mFramesPerPacket: 1,
            mBytesPerFrame: 2,  // 16-bit = 2 bytes
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

        Self.default.log("Microphone input format: \(inputFormat)")
        Self.default.log("Desired output format: \(outputFormat)")

        // Create the audio converter once
        self.audioConverter = AVAudioConverter(from: inputFormat, to: outputFormat)
        if self.audioConverter == nil {
            DispatchQueue.main.async {
                self.errorMessage =
                    "Failed to create audio converter. Input: \(inputFormat), Output: \(outputFormat)"
            }
            return
        }

        // Explicitly set sample rate converter quality
        self.audioConverter?.sampleRateConverterQuality = AVAudioQuality.high.rawValue

        // Install a tap on the input node to capture audio
        audioInputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) {
            [weak self] (buffer, time) in
            guard let self = self, let converter = self.audioConverter else { return }

            // The frame capacity of the output buffer must be calculated based on the sample rate ratio.
            let ratio =
                inputFormat.sampleRate > 0 ? outputFormat.sampleRate / inputFormat.sampleRate : 1.0
            let outputFrameCapacity = AVAudioFrameCount(ceil(Double(buffer.frameLength) * ratio))
            guard
                let pcmBuffer = AVAudioPCMBuffer(
                    pcmFormat: outputFormat, frameCapacity: outputFrameCapacity)
            else {
                Self.default.error("Failed to create PCM buffer for conversion")
                return
            }

            var error: NSError? = nil

            let inputBlock: AVAudioConverterInputBlock = { inNumPackets, outStatus in
                outStatus.pointee = .haveData
                return buffer
            }

            converter.convert(to: pcmBuffer, error: &error, withInputFrom: inputBlock)

            if let error = error {
                Self.default.error("Error during conversion: \(error.localizedDescription)")
                return
            }

            // Convert AVAudioPCMBuffer to Data
            guard let channelData = pcmBuffer.int16ChannelData else {
                Self.default.error("Error: Failed to get channel data from PCM buffer.")
                return
            }
            let frameLength = Int(pcmBuffer.frameLength)
            let data = Data(bytes: channelData[0], count: frameLength * MemoryLayout<Int16>.size)

            // Append to pcmData for saving
            self.pcmData?.append(data)

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
            Self.default.log("Microphone recording started.")
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to start audio engine: \(error.localizedDescription)"
            }
            Self.default.error("Error starting audio engine: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        guard isRecording else { return }

        audioEngine?.stop()
        audioInputNode?.removeTap(onBus: 0)
        audioEngine = nil
        audioInputNode = nil
        isRecording = false
        pcmData = nil
        audioStreamContinuation?.finish()  // Signal that the stream is complete
        audioStreamContinuation = nil
        audioStream = nil
        audioConverter = nil  // Clear the converter when stopping
        Self.default.log("Microphone recording stopped.")
    }

    func saveRecording() -> String? {
        guard let data = pcmData, !data.isEmpty else {
            Self.default.warning("No PCM data to save.")
            return nil
        }

        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd-HHmmss"
        let dateString = dateFormatter.string(from: Date())
        let fileName = "recording-\(dateString).pcm"

        let fileURL = documentDirectory.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            Self.default.log("Saved PCM data to \(fileURL.path)")
            return fileName
        } catch {
            Self.default.error("Error saving PCM data: \(error.localizedDescription)")
            return nil
        }
    }

    func pauseRecording() {
        guard isRecording else { return }
        audioEngine?.pause()
        isRecording = false
        Self.default.log("Microphone recording paused.")
    }

    func resumeRecording() {
        guard !isRecording else { return }
        do {
            try audioEngine?.start()
            isRecording = true
            Self.default.log("Microphone recording resumed.")
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to resume audio engine: \(error.localizedDescription)"
            }
            Self.default.error("Error resuming audio engine: \(error.localizedDescription)")
        }
    }
}
