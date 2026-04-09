import Foundation

struct ParsedReminderInput {
    var cleanedTitle: String
    var categoryHint: String?
    var trigger: ReminderTrigger
    var priority: Priority?
    var repeatFrequency: RepeatFrequency?
    var sectionName: String?
    var tags: [String]
}

struct NaturalLanguageParser {
    private let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)

    func parse(_ input: String) -> ParsedReminderInput {
        let lowercase = input.lowercased()
        var stripped = input
        var trigger: ReminderTrigger = .none
        var categoryHint: String?

        if lowercase.contains("home") { categoryHint = "Home" }
        if lowercase.contains("arcade") { categoryHint = "Arcade" }

        if lowercase.contains("focus mode") || lowercase.contains("when i open") || lowercase.contains("mode") {
            let modeName = extractModeName(from: input) ?? "Focus"
            trigger = .appMode(modeName)
        }

        if let dueDate = detectDueDate(in: input) ?? detectDate(in: input) {
            trigger = .time(dueDate)
        }

        let tags = extractTags(from: input)
        let priority = extractPriority(from: lowercase)
        let repeatFrequency = extractRepeat(from: lowercase)
        let section = extractSection(from: input)

        stripped = stripped
            .replacingOccurrences(of: "remind me to", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "remind me", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "due", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "tmrw", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "tomorrow", with: "", options: .caseInsensitive)

        if let cleaned = removeTimeSnippet(from: stripped) { stripped = cleaned }
        stripped = stripTags(from: stripped).trimmingCharacters(in: .whitespacesAndNewlines)

        return ParsedReminderInput(
            cleanedTitle: stripped.isEmpty ? input : stripped,
            categoryHint: categoryHint,
            trigger: trigger,
            priority: priority,
            repeatFrequency: repeatFrequency,
            sectionName: section,
            tags: tags
        )
    }

    private func detectDate(in text: String) -> Date? {
        guard let detector else { return nil }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return detector.firstMatch(in: text, options: [], range: range)?.date
    }

    private func detectDueDate(in text: String) -> Date? {
        let lower = text.lowercased()
        guard lower.contains("due") || lower.contains("tmrw") || lower.contains("tomorrow") else { return nil }

        let baseDate = lower.contains("tmrw") || lower.contains("tomorrow")
            ? (Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now)
            : .now

        guard let time = extractClockTime(from: lower) else { return Calendar.current.startOfDay(for: baseDate) }
        return combine(date: baseDate, hour: time.hour, minute: time.minute)
    }

    private func extractClockTime(from text: String) -> (hour: Int, minute: Int)? {
        let pattern = #"\b(\d{1,2})(?::(\d{2}))?\s*(am|pm)?\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: range) else { return nil }

        guard var hour = Int(substring(text, from: match.range(at: 1))) else { return nil }
        let minute = Int(substring(text, from: match.range(at: 2))) ?? 0
        let period = substring(text, from: match.range(at: 3))

        if period == "pm" && hour < 12 { hour += 12 }
        if period == "am" && hour == 12 { hour = 0 }
        return (hour, minute)
    }

    private func extractPriority(from text: String) -> Priority? {
        if text.contains("high priority") || text.contains("p1") || text.contains("!!!") { return .high }
        if text.contains("low priority") || text.contains("p3") { return .low }
        return nil
    }

    private func extractRepeat(from text: String) -> RepeatFrequency? {
        if text.contains("every day") || text.contains("daily") { return .daily }
        if text.contains("every week") || text.contains("weekly") { return .weekly }
        if text.contains("every month") || text.contains("monthly") { return .monthly }
        return nil
    }

    private func extractSection(from text: String) -> String? {
        guard let range = text.range(of: "section ", options: .caseInsensitive) else { return nil }
        let value = text[range.upperBound...].split(separator: " ").prefix(2).joined(separator: " ")
        return value.isEmpty ? nil : value
    }

    private func extractTags(from text: String) -> [String] {
        text.split(separator: " ")
            .filter { $0.hasPrefix("#") && $0.count > 1 }
            .map { String($0.dropFirst()) }
    }

    private func stripTags(from text: String) -> String {
        text.split(separator: " ").filter { !$0.hasPrefix("#") }.joined(separator: " ")
    }

    private func combine(date: Date, hour: Int, minute: Int) -> Date? {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        comps.hour = hour
        comps.minute = minute
        return Calendar.current.date(from: comps)
    }

    private func substring(_ text: String, from range: NSRange) -> String {
        guard range.location != NSNotFound, let swiftRange = Range(range, in: text) else { return "" }
        return String(text[swiftRange]).lowercased()
    }

    private func removeTimeSnippet(from text: String) -> String? {
        let pattern = #"\b\d{1,2}(?::\d{2})?\s*(am|pm)?\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let reduced = regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "")
        return reduced.replacingOccurrences(of: "  ", with: " ")
    }

    private func extractModeName(from text: String) -> String? {
        let lowered = text.lowercased()
        guard let openRange = lowered.range(of: "open ") else { return nil }
        let slice = text[openRange.upperBound...]
        return slice.components(separatedBy: " ").prefix(2).joined(separator: " ")
    }
}
