import SwiftUI
import SwiftData

struct CameraHistoryView: View {
    @Query(sort: \CameraCaptureItem.createdAt, order: .reverse)
    private var captures: [CameraCaptureItem]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            if captures.isEmpty {
                ContentUnavailableView(
                    "No Saves",
                    systemImage: "camera",
                    description: Text("Saved camera translations will appear here")
                )
            } else {
                ForEach(captures) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.translatedText)
                            .font(.body)

                        Text(item.extractedText)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(item.createdAt, style: .date) + Text(" ") + Text(item.createdAt, style: .time)
                    }
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Camera History")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
    }
}
