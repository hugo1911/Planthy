import SwiftUI

struct HistoryView: View {
    @Environment(HistoryStore.self) private var historyStore

    var body: some View {
        NavigationStack {
            Group {
                if historyStore.results.isEmpty {
                    emptyState
                } else {
                    resultList
                }
            }
            .navigationTitle("Recientes")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Sin análisis recientes")
                .foregroundStyle(.secondary)
        }
    }

    private var resultList: some View {
        List(historyStore.results) { result in
            HStack(spacing: 12) {
                Image(uiImage: result.thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: result.plantClass.icon)
                            .foregroundStyle(iconColor(for: result.plantClass))
                        Text(result.plantClass.displayName)
                            .font(.headline)
                    }
                    Text(String(format: "%.1f%% confianza", result.confidence * 100))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(result.date, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func iconColor(for cls: PlantClass) -> Color {
        switch cls {
        case .healthy: return .green
        case .rust:    return .orange
        case .powdery: return .red
        }
    }
}
