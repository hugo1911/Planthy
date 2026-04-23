import SwiftUI

struct ResultView: View {
    let result: AnalysisResult
    let onAnalyzeAnother: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                thumbnail
                classCard
                recommendationCard
                analyzeAnotherButton
            }
            .padding()
        }
        .navigationTitle("Resultado")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }

    private var thumbnail: some View {
        Image(uiImage: result.thumbnail)
            .resizable()
            .scaledToFit()
            .frame(maxHeight: 240)
            .cornerRadius(12)
    }

    private var classCard: some View {
        HStack(spacing: 12) {
            Image(systemName: result.plantClass.icon)
                .font(.system(size: 36))
                .foregroundStyle(iconColor)
            VStack(alignment: .leading) {
                Text(result.plantClass.displayName)
                    .font(.title2.bold())
            }
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var confidenceBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Confianza")
                .font(.subheadline.bold())
            ProgressView(value: result.confidence)
                .tint(iconColor)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var probabilityTable: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Probabilidades por clase")
                .font(.subheadline.bold())
            ForEach(PlantClass.allCases, id: \.self) { cls in
                let prob = result.allProbabilities[cls] ?? 0
                HStack {
                    Text(cls.displayName)
                        .frame(width: 90, alignment: .leading)
                    ProgressView(value: prob)
                        .tint(cls == result.plantClass ? iconColor : .gray)
                    Text(String(format: "%.1f%%", prob * 100))
                        .frame(width: 50, alignment: .trailing)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var recommendationCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Recomendación", systemImage: "info.circle")
                .font(.subheadline.bold())
            Text(result.plantClass.recommendation)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var analyzeAnotherButton: some View {
        Button {
            onAnalyzeAnother()
        } label: {
            Text("Analizar otra planta")
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .fontWeight(.semibold)
        }
        .buttonStyle(.borderedProminent)
        .tint(.green)
    }

    private var iconColor: Color {
        switch result.plantClass {
        case .healthy: return .green
        case .rust:    return .orange
        case .powdery: return .red
        }
    }
}
