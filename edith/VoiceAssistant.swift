import Foundation
import AVFoundation
import Speech
#if canImport(AIProxy)
import AIProxy
#endif

// MARK: - Simple Speech Recorder
class SpeechRecorderAndTranscriber {
    let recorder = AVAudioRecorder()
    var currentAudioUrl = ""

    func startRecording() {
        if(currentAudioUrl != "") {
            currentAudioUrl = ""
        }

        do {
            let success = try recorder.prepareToRecord()
            if success {
                recorder.record()
            } else {
                print("Failed to prepare to record")
            }
        } catch {
            print("Error preparing to record: \(error)")
        }
    }

    func transcribe(completion: @escaping (Result<String, Error>) -> Void) {
        guard !currentAudioUrl.isEmpty else {
            completion(.failure(NSError(domain: "RecordingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No audio recording available"])))
            return
        }

        guard let url = URL(string: currentAudioUrl) else {
            completion(.failure(NSError(domain: "RecordingError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid audio URL"])))
            return
        }

        AIManager.shared.transcribeAudio(from: url, completion: completion)
    }

    func stopRecording () {
        recorder.stop()
        currentAudioUrl = recorder.url.absoluteString

        transcribe { result in
            switch result {
            case .success(let transcript):
                print("Transcription: \(transcript)")
                // Process the transcript further if needed
            case .failure(let error):
                print("Transcription error: \(error.localizedDescription)")
            }
        }
    }

    public func getCurrentAudioUrl() -> String {
        return currentAudioUrl
    }

    func transcribe() {

    }
}


// MARK: - Recording Errors
enum RecordingError: Error, LocalizedError {
    case speechRecognizerNotAvailable
    case unableToCreateRequest
    case audioEngineError

    var errorDescription: String? {
        switch self {
        case .speechRecognizerNotAvailable:
            return "Speech recognizer is not available"
        case .unableToCreateRequest:
            return "Unable to create speech recognition request"
        case .audioEngineError:
            return "Audio engine error"
        }
    }
}

// MARK: - AI Manager
class AIManager {
    static let shared = AIManager()

    #if canImport(AIProxy)
    private let groqService = AIProxy.groqDirectService(
        unprotectedAPIKey: "KEY HERE"
    )
    #endif

    private init() {}

    func transcribeAudio(from url: URL, completion: @escaping (Result<String, Error>) -> Void) {
        #if canImport(AIProxy)
        Task {
            do {
                let audioData = try Data(contentsOf: url)
                let requestBody = GroqTranscriptionRequstBody(
                    file: audioData,
                    model: "whisper-large-v3-turbo",
                    responseFormat: .json
                )
                let response = try await groqService.createTranscriptionRequest(body: requestBody)
                let transcript = responseText.text ?? "None"
                print("Groq transcribed: \(transcript)")
                completion(.success(transcription))
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        #else
        completion(.failure(NSError(domain: "AIProxyError", code: 0, userInfo: [NSLocalizedDescriptionKey: "AIProxy not available"])))
        #endif
    }

    func processTranscript(_ text: String, completion: @escaping (String) -> Void) {
        // TODO: Send text to LLM and get response
        // For now, return simple echo
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion("I heard you say: \(text)")
        }
    }
}

// MARK: - Text-to-Speech
class SpeechSynthesizer {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }

    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}

// MARK: - Voice Assistant Main Class
class VoiceAssistant {
    let recorder = SpeechRecorder.shared
    let aiManager = AIManager()
    let synthesizer = SpeechSynthesizer()

    // Callbacks for UI updates
    var onTranscriptionUpdate: ((String) -> Void)?
    var onResponseReceived: ((String) -> Void)?

    init() {
        setupRecorderCallbacks()
    }

    private func setupRecorderCallbacks() {
        recorder.onTranscription = { [weak self] transcript, isFinal in
            DispatchQueue.main.async {
                self?.onTranscriptionUpdate?(transcript)

                // When transcription is final, process with AI
                if isFinal && !transcript.isEmpty {
                    self?.processWithAI(transcript)
                }
            }
        }
    }

    func startRecording() throws {
        try recorder.startRecording()
    }

    func stopRecording() {
        recorder.stopRecording()
    }

    func isRecording() -> Bool {
        return recorder.isCurrentlyRecording
    }

    private func processWithAI(_ transcript: String) {
        aiManager.processTranscript(transcript) { [weak self] response in
            DispatchQueue.main.async {
                self?.onResponseReceived?(response)
                self?.synthesizer.speak(response)
            }
        }
    }

    func speak(_ text: String) {
        synthesizer.speak(text)
    }

    func stopSpeaking() {
        synthesizer.stopSpeaking()
    }
}
