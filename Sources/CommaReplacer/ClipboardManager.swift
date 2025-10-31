import AppKit
import Combine
import Foundation

final class ClipboardManager: ObservableObject {
    @Published var isMonitoring: Bool {
        didSet {
            guard oldValue != isMonitoring else { return }
            persistMonitoringState()
            if isMonitoring {
                startMonitoring()
            } else {
                stopMonitoring()
            }
        }
    }

    @Published var lastOriginalText: String?
    @Published var lastProcessedText: String?
    @Published var appliedRules: [ReplacementRule] = []
    @Published var showPasteDialog: Bool = false
    @Published var rules: [ReplacementRule] {
        didSet {
            persistRules()
        }
    }

    var onReplacementDetected: (() -> Void)?

    private let pasteboard: NSPasteboard
    private let userDefaults: UserDefaults
    private var changeCount: Int
    private var monitorTimer: Timer?
    private var isUpdatingPasteboard = false

    private enum DefaultsKeys {
        static let monitoringEnabled = "com.commareplacer.settings.monitoringEnabled"
        static let rules = "com.commareplacer.settings.rules"
    }

    init(pasteboard: NSPasteboard = .general, userDefaults: UserDefaults = .standard) {
        self.pasteboard = pasteboard
        self.userDefaults = userDefaults
        self.rules = ClipboardManager.loadRules(from: userDefaults)

        if let storedValue = userDefaults.object(forKey: DefaultsKeys.monitoringEnabled) as? Bool {
            self.isMonitoring = storedValue
        } else {
            self.isMonitoring = true
        }

        self.changeCount = pasteboard.changeCount

        if isMonitoring {
            startMonitoring()
        }
    }

    deinit {
        stopMonitoring()
    }

    func startMonitoring() {
        guard monitorTimer == nil else { return }

        changeCount = pasteboard.changeCount

        let timer = Timer(timeInterval: 0.6, repeats: true) { [weak self] _ in
            self?.pollPasteboard()
        }
        monitorTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func stopMonitoring() {
        monitorTimer?.invalidate()
        monitorTimer = nil
    }

    func addRule(source: String, target: String) {
        let trimmedSource = source.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTarget = target.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSource.isEmpty else { return }

        let rule = ReplacementRule(source: trimmedSource, target: trimmedTarget.isEmpty ? trimmedSource : trimmedTarget)
        rules.append(rule)
    }

    func removeRules(at offsets: IndexSet) {
        rules.remove(atOffsets: offsets)
    }

    func removeRule(_ rule: ReplacementRule) {
        rules.removeAll { $0.id == rule.id }
    }

    func resetToDefaultRules() {
        rules = ClipboardManager.defaultRules
    }

    func copyOriginalText() {
        guard let original = lastOriginalText else { return }
        writeToPasteboard(original)
        showPasteDialog = false
    }

    func copyProcessedText() {
        guard let processed = lastProcessedText else { return }
        writeToPasteboard(processed)
        showPasteDialog = false
    }

    func dismissSuggestions() {
        showPasteDialog = false
    }

    private func pollPasteboard() {
        guard isMonitoring else { return }

        let currentChangeCount = pasteboard.changeCount
        guard currentChangeCount != changeCount else { return }
        changeCount = currentChangeCount

        if isUpdatingPasteboard {
            isUpdatingPasteboard = false
            return
        }

        guard let latest = pasteboard.string(forType: .string), !latest.isEmpty else { return }

        let result = TextProcessor.process(latest, using: rules)

        guard result.hasChanges else {
            lastOriginalText = result.original
            lastProcessedText = result.processed
            appliedRules = []
            showPasteDialog = false
            return
        }

        lastOriginalText = result.original
        lastProcessedText = result.processed
        appliedRules = result.appliedRules
        showPasteDialog = true
        onReplacementDetected?()
    }

    private func writeToPasteboard(_ text: String) {
        isUpdatingPasteboard = true
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        changeCount = pasteboard.changeCount
    }

    private func persistMonitoringState() {
        userDefaults.set(isMonitoring, forKey: DefaultsKeys.monitoringEnabled)
    }

    private func persistRules() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(rules)
            userDefaults.set(data, forKey: DefaultsKeys.rules)
        } catch {
            NSLog("Failed to persist rules: %@", error.localizedDescription)
        }
    }

    private static func loadRules(from defaults: UserDefaults) -> [ReplacementRule] {
        guard let data = defaults.data(forKey: DefaultsKeys.rules) else {
            return defaultRules
        }

        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode([ReplacementRule].self, from: data)
            return decoded.isEmpty ? defaultRules : decoded
        } catch {
            NSLog("Failed to load persisted rules: %@", error.localizedDescription)
            return defaultRules
        }
    }

    private static let defaultRules: [ReplacementRule] = [
        ReplacementRule(source: "，", target: ","),
        ReplacementRule(source: "。", target: "."),
        ReplacementRule(source: "！", target: "!"),
        ReplacementRule(source: "？", target: "?"),
        ReplacementRule(source: "：", target: ":"),
        ReplacementRule(source: "；", target: ";")
    ]
}
