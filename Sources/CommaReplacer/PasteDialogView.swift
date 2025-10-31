import SwiftUI

struct PasteDialogView: View {
    let originalText: String
    let replacedText: String
    let appliedRules: [ReplacementRule]
    let useOriginalAction: () -> Void
    let useReplacedAction: () -> Void
    let dismissAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("粘贴选项")
                .font(.title3)
                .fontWeight(.semibold)

            VStack(spacing: 12) {
                GroupBox {
                    ScrollView {
                        Text(originalText)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                    .frame(maxHeight: 80)
                } label: {
                    Label("原文", systemImage: "doc.plaintext")
                        .font(.caption)
                }

                GroupBox {
                    ScrollView {
                        Text(replacedText)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                    .frame(maxHeight: 80)
                } label: {
                    Label("替换后", systemImage: "doc.richtext")
                        .font(.caption)
                }
            }

            if !appliedRules.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("应用的规则")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ForEach(appliedRules) { rule in
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 12))
                            Text("\(rule.source) → \(rule.target)")
                                .font(.caption)
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
            }

            HStack {
                Button("粘贴原文") {
                    useOriginalAction()
                }
                Button("粘贴替换后文本") {
                    useReplacedAction()
                }
                .buttonStyle(.borderedProminent)

                Spacer()

                Button("忽略") {
                    dismissAction()
                }
                .buttonStyle(.borderless)
            }
            .padding(.top, 4)
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}
