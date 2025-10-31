import XCTest
@testable import CommaReplacer

final class TextProcessorTests: XCTestCase {
    func testChineseCommaIsReplaced() {
        let rules = [ReplacementRule(source: "，", target: ",")]
        let result = TextProcessor.process("你好，世界", using: rules)

        XCTAssertTrue(result.hasChanges)
        XCTAssertEqual(result.processed, "你好,世界")
        XCTAssertEqual(result.appliedRules.count, 1)
        XCTAssertEqual(result.appliedRules.first?.source, "，")
    }

    func testDisabledRuleIsIgnored() {
        let rules = [ReplacementRule(source: "，", target: ",", isEnabled: false)]
        let result = TextProcessor.process("你好，世界", using: rules)

        XCTAssertFalse(result.hasChanges)
        XCTAssertEqual(result.processed, "你好，世界")
        XCTAssertTrue(result.appliedRules.isEmpty)
    }

    func testMultipleRulesAppliedSequentially() {
        let rules = [
            ReplacementRule(source: "，", target: ","),
            ReplacementRule(source: "。", target: ".")
        ]

        let result = TextProcessor.process("你好，世界。", using: rules)

        XCTAssertEqual(result.processed, "你好,世界.")
        XCTAssertEqual(result.appliedRules.count, 2)
    }
}
