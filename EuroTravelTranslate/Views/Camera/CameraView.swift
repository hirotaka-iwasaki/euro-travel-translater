import SwiftUI
import VisionKit

struct CameraView: View {
    @Environment(TranslationBridgeController.self) private var bridgeController
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = CameraViewModel()
    @State private var showHistory = false

    var body: some View {
        ZStack {
            if AppleTextScanner.isSupported {
                scannerView
                overlayLabels
                toolbar
            } else {
                ContentUnavailableView(
                    "Camera Not Available",
                    systemImage: "camera.fill",
                    description: Text("DataScanner is not supported on this device")
                )
            }
        }
        .navigationTitle("Camera")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                languagePicker
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showHistory = true
                } label: {
                    Label("History", systemImage: "clock")
                }
            }
        }
        .sheet(isPresented: $showHistory) {
            NavigationStack {
                CameraHistoryView()
            }
        }
        .onAppear {
            let service = AppleTranslatorService(bridgeController: bridgeController)
            viewModel.setup(translatorService: service, modelContext: modelContext)
        }
    }

    private var scannerView: some View {
        DataScannerRepresentable(
            recognizedLanguages: recognizedLanguages,
            onTextFound: { elements in
                Task { @MainActor in
                    viewModel.handleScannedElements(elements)
                }
            },
            isFrozen: $viewModel.isFrozen
        )
        .ignoresSafeArea()
    }

    private var overlayLabels: some View {
        ForEach(viewModel.translatedOverlays) { overlay in
            OverlayLabelView(overlay: overlay)
        }
    }

    private var toolbar: some View {
        VStack {
            Spacer()
            HStack(spacing: 20) {
                Button {
                    viewModel.toggleFreeze()
                } label: {
                    Label(
                        viewModel.isFrozen ? "Resume" : "Freeze",
                        systemImage: viewModel.isFrozen ? "play.fill" : "pause.fill"
                    )
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
                }

                Button {
                    viewModel.save()
                } label: {
                    Label("Save", systemImage: "square.and.arrow.down")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                .disabled(viewModel.translatedOverlays.isEmpty)
            }
            .padding(.bottom, 30)
        }
    }

    private var languagePicker: some View {
        Menu {
            ForEach(LanguageCode.sourceLanguages) { lang in
                Button {
                    viewModel.selectedLang = lang
                } label: {
                    if viewModel.selectedLang == lang {
                        Label(lang.displayName, systemImage: "checkmark")
                    } else {
                        Text(lang.displayName)
                    }
                }
            }
        } label: {
            Text(viewModel.selectedLang.shortLabel)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }

    private var recognizedLanguages: [String] {
        if viewModel.selectedLang == .auto {
            return ["en", "fr", "de", "es", "it", "pt", "nl"]
        }
        return [viewModel.selectedLang.rawValue]
    }
}
