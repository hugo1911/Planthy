import SwiftUI
import PhotosUI

struct AnalysisView: View {
    @State private var viewModel: AnalysisViewModel
    @Environment(HistoryStore.self) private var historyStore

    init(historyStore: HistoryStore) {
        _viewModel = State(wrappedValue: AnalysisViewModel(historyStore: historyStore))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                imagePreview
                pickerButtons
                analyzeButton
            }
            .padding()
            .navigationTitle("Planthy")
            .navigationDestination(isPresented: $viewModel.navigateToResult) {
                if let result = viewModel.latestResult {
                    ResultView(result: result) {
                        viewModel.reset()
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "Error desconocido")
            }
            .onChange(of: viewModel.selectedItem) {
                Task { await viewModel.loadSelectedImage() }
            }
        }
    }

    @ViewBuilder
    private var imagePreview: some View {
        if let image = viewModel.selectedImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 300)
                .cornerRadius(12)
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .frame(height: 300)
                .overlay {
                    VStack(spacing: 8) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.green)
                        Text("Selecciona una imagen")
                            .foregroundStyle(.secondary)
                    }
                }
        }
    }

    private var pickerButtons: some View {
        HStack(spacing: 16) {
            PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                Label("Galería", systemImage: "photo.on.rectangle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button {
                // Handled by CameraButton overlay
            } label: {
                Label("Cámara", systemImage: "camera")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .overlay { CameraButton(image: $viewModel.selectedImage) }
        }
    }

    private var analyzeButton: some View {
        Button {
            Task { await viewModel.analyze() }
        } label: {
            Group {
                if viewModel.isAnalyzing {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else {
                    Text("Analizar planta")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .buttonStyle(.borderedProminent)
        .tint(.green)
        .disabled(viewModel.selectedImage == nil || viewModel.isAnalyzing)
    }
}

// MARK: - Camera bridge

private struct CameraButton: View {
    @Binding var image: UIImage?
    @State private var showCamera = false

    var body: some View {
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture { showCamera = true }
            .sheet(isPresented: $showCamera) {
                CameraPicker(image: $image)
                    .ignoresSafeArea()
            }
    }
}

private struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            parent.image = info[.originalImage] as? UIImage
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
