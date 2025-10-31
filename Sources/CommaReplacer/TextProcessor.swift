import Foundation

struct ReplacementRule: Identifiable, Codable, Hashable {
    let id: UUID
    var source: String
    var target: String
    var isEnabled: Bool

    init(id: UUID = UUID(), source: String, target: String, isEnabled: Bool = true) {
        self.id = id
        self.source = source
        self.target = target
        self.isEnabled = isEnabled
    }
}

struct ProcessingResult {
    let original: String
    let processed: String
    let appliedRules: [ReplacementRule]

    var hasChanges: Bool {
        processed != original
    }
}

enum TextProcessor {
    static func process(_ text: String, using rules: [ReplacementRule]) -> ProcessingResult {
        guard !text.isEmpty else {
            return ProcessingResult(original: text, processed: text, appliedRules: [])
        }

        var updated = text
        var applied: [ReplacementRule] = []

        for rule in rules where rule.isEnabled && !rule.source.isEmpty {
            let replaced = updated.replacingOccurrences(of: rule.source, with: rule.target)
            if replaced != updated {
                updated = replaced
                applied.append(rule)
            }
        }

        return ProcessingResult(original: text, processed: updated, appliedRules: applied)
    }
}
