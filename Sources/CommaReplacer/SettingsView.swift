import SwiftUI

struct SettingsView: View {
    @ObservedObject var clipboardManager: ClipboardManager

    var body: some View {
        AppMenuView(clipboardManager: clipboardManager, onClose: nil, showsExitButton: false)
            .frame(width: 360, height: 520)
    }
}
