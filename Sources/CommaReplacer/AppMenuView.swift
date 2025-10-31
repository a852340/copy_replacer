import SwiftUI
import AppKit

struct AppMenuView: View {
    @ObservedObject var clipboardManager: ClipboardManager
    var onClose: (() -> Void)?
    var showsExitButton: Bool = true

    @State private var showingAddRule = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            Toggle("启用剪切板监听", isOn: $clipboardManager.isMonitoring)
                .toggleStyle(.switch)

            Divider()

            suggestionSection

            Divider()

            rulesSection

            if showsExitButton {
                Divider()

                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Label("退出应用", systemImage: "power")
                        .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .frame(width: 320)
        .sheet(isPresented: $showingAddRule) {
            AddRuleView { source, target in
                clipboardManager.addRule(source: source, target: target)
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("逗号替换器")
                    .font(.headline)
                Text("自动将中文标点替换为英文标点")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if let onClose {
                Button {
                    onClose()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .padding(6)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("关闭")
            }
        }
    }

    private var suggestionSection: some View {
        Group {
            if let original = clipboardManager.lastOriginalText,
               let processed = clipboardManager.lastProcessedText,
               clipboardManager.showPasteDialog {
                PasteDialogView(
                    originalText: original,
                    replacedText: processed,
                    appliedRules: clipboardManager.appliedRules,
                    useOriginalAction: {
                        clipboardManager.copyOriginalText()
                        onClose?()
                    },
                    useReplacedAction: {
                        clipboardManager.copyProcessedText()
                        onClose?()
                    },
                    dismissAction: {
                        clipboardManager.dismissSuggestions()
                        onClose?()
                    }
                )
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Label("等待新的剪切板内容…", systemImage: "doc.on.clipboard")
                        .font(.callout)
                        .foregroundColor(.secondary)
                    Text("复制包含中文标点的文本即可收到替换建议。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var rulesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("替换规则")
                    .font(.subheadline)
                    .bold()
                Spacer()
                Button {
                    showingAddRule = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
                .help("添加新的替换规则")
            }

            if clipboardManager.rules.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("当前没有启用的替换规则。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button("恢复默认规则") {
                        clipboardManager.resetToDefaultRules()
                    }
                    .buttonStyle(.link)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach($clipboardManager.rules) { $rule in
                            RuleRow(rule: $rule) {
                                clipboardManager.removeRule(rule)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 180)
            }
        }
    }
}

private struct RuleRow: View {
    @Binding var rule: ReplacementRule
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                Toggle("启用", isOn: $rule.isEnabled)
                    .toggleStyle(.switch)
                    .labelsHidden()

                Spacer()

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("删除该规则")
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("原始")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 36, alignment: .leading)
                    TextField("", text: $rule.source)
                        .textFieldStyle(.roundedBorder)
                }
                HStack {
                    Text("替换")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 36, alignment: .leading)
                    TextField("", text: $rule.target)
                        .textFieldStyle(.roundedBorder)
                }
            }
        }
        .padding(12)
        .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
    }
}

private struct AddRuleView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var source: String = ""
    @State private var target: String = ""

    let onAdd: (String, String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("添加替换规则")
                .font(.headline)

            TextField("需要替换的符号", text: $source)
                .textFieldStyle(.roundedBorder)

            TextField("替换为", text: $target)
                .textFieldStyle(.roundedBorder)

            HStack {
                Spacer()
                Button("取消") {
                    dismiss()
                }
                Button("添加") {
                    onAdd(source, target)
                    dismiss()
                    source = ""
                    target = ""
                }
                .disabled(source.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.top, 8)
        }
        .padding(24)
        .frame(width: 320)
    }
}
