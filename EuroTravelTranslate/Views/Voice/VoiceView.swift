import SwiftUI
import SwiftData

struct VoiceView: View {
    @Environment(TranslationBridgeController.self) private var bridgeController
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = VoiceViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Language selector
            languageSelector

            // Recording button
            recordingButton

            // Content
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        transcriptSection
                        translationSection
                        replySection
                    }
                    .padding()
                }
                .onChange(of: viewModel.transcripts.count) {
                    if let last = viewModel.transcripts.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .navigationTitle("Voice")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    VoiceHistoryView()
                } label: {
                    Label("History", systemImage: "clock")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.clearSession()
                } label: {
                    Label("Clear", systemImage: "trash")
                }
                .disabled(viewModel.transcripts.isEmpty)
            }
        }
        .onAppear {
            let service = AppleTranslatorService(bridgeController: bridgeController)
            viewModel.setup(translatorService: service, modelContext: modelContext)
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var languageSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(LanguageCode.sourceLanguages) { lang in
                    Button {
                        viewModel.selectedLang = lang
                    } label: {
                        Text(lang.shortLabel)
                            .font(.subheadline)
                            .fontWeight(viewModel.selectedLang == lang ? .bold : .regular)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                viewModel.selectedLang == lang ? Color.accentColor : Color(.systemGray5),
                                in: Capsule()
                            )
                            .foregroundStyle(viewModel.selectedLang == lang ? .white : .primary)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }

    private var recordingButton: some View {
        Button {
            viewModel.toggleListening()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: viewModel.isListening ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.title2)
                Text(viewModel.isListening ? "Stop" : "Start Listening")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(viewModel.isListening ? Color.red : Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(.white)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var transcriptSection: some View {
        if !viewModel.transcripts.isEmpty || !viewModel.partialText.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Transcript")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                ForEach(viewModel.transcripts) { entry in
                    TranscriptRow(text: entry.text, lang: entry.lang)
                        .id(entry.id)
                }

                if !viewModel.partialText.isEmpty {
                    Text(viewModel.partialText)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }
        }
    }

    @ViewBuilder
    private var translationSection: some View {
        if !viewModel.translations.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("日本語訳")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                ForEach(viewModel.translations) { entry in
                    TranslationRow(
                        sourceText: entry.sourceText,
                        translatedText: entry.translatedText
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var replySection: some View {
        if !viewModel.replySuggestions.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Reply Suggestions")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Picker("Style", selection: $viewModel.politeStyle) {
                        Text("Polite").tag(true)
                        Text("Casual").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 160)
                }

                ForEach(viewModel.replySuggestions) { suggestion in
                    ReplySuggestionRow(
                        suggestion: suggestion,
                        onCopy: { viewModel.copiedToast = true },
                        onSpeak: { viewModel.speakSuggestion(suggestion) }
                    )
                }
            }
        }
    }
}
