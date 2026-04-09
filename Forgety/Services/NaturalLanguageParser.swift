import Foundation

struct ParsedReminderInput {
    var cleanedTitle: String
    var categoryHint: String?
    var trigger: ReminderTrigger
}

struct NaturalLanguageParser {
    private let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)

    func parse(_ input: String) -> ParsedReminderInput {
        let lowercase = input.lowercased()
        var stripped = input
        var trigger: ReminderTrigger = .none
        var categoryHint: String?

        if lowercase.contains("home") {
            categoryHint = "Home"
        } else if lowercase.contains("arcade") {
            categoryHint = "Arcade"
        }

        if lowercase.contains("when i get home") || lowercase.contains("arrive home") {
            trigger = .arrival(LocationTrigger(label: "Home", latitude: nil, longitude: nil))
            stripped = stripped.replacingOccurrences(of: "Remind me when I get home to", with: "", options: .caseInsensitive)
        } else if lowercase.contains("when i leave") {
            trigger = .departure(LocationTrigger(label: "Current Location", latitude: nil, longitude: nil))
        } else if lowercase.contains("wifi") || lowercase.contains("wi-fi") {
            let ssid = extractWifiName(from: input) ?? "Known Network"
            trigger = .wifi(ssid)
        } else if lowercase.contains("when i open") || lowercase.contains("mode") {
            let modeName = extractModeName(from: input) ?? "Mode"
            trigger = .appMode(modeName)
        } else if lowercase.contains("school") {
            trigger = .location(LocationTrigger(label: "School", latitude: nil, longitude: nil))
        }

        if let dueDate = detectDueDate(in: input) ?? detectDate(in: input) {
            trigger = .time(dueDate)
        }

        stripped = stripped
            .replacingOccurrences(of: "remind me to", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "remind me", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "due", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "tmrw", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "tomorrow", with: "", options: .caseInsensitive)

        if let cleaned = removeTimeSnippet(from: stripped) {
            stripped = cleaned
        }

        stripped = stripped.trimmingCharacters(in: .whitespacesAndNewlines)

        return ParsedReminderInput(cleanedTitle: stripped.isEmpty ? input : stripped, categoryHint: categoryHint, trigger: trigger)
    }

    private func detectDate(in text: String) -> Date? {
        guard let detector else { return nil }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let result = detector.firstMatch(in: text, options: [], range: range)
        return result?.date
    }

    private func detectDueDate(in text: String) -> Date? {
        let lower = text.lowercased()
        guard lower.contains("due") || lower.contains("tmrw") || lower.contains("tomorrow") else {
            return nil
        }

        let baseDate: Date = {
            if lower.contains("tmrw") || lower.contains("tomorrow") {
                return Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
            }
            return .now
        }()

        let time = extractClockTime(from: lower)
        guard let time else { return Calendar.current.startOfDay(for: baseDate) }
        return combine(date: baseDate, hour: time.hour, minute: time.minute)
    }

    private func extractClockTime(from text: String) -> (hour: Int, minute: Int)? {
        let pattern = #"\b(\d{1,2})(?::(\d{2}))?\s*(am|pm)?\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: range) else { return nil }

        let hourText = substring(text, from: match.range(at: 1))
        let minuteText = substring(text, from: match.range(at: 2))
        let period = substring(text, from: match.range(at: 3))

        guard var hour = Int(hourText) else { return nil }
        let minute = Int(minuteText) ?? 0

        if period == "pm" && hour < 12 { hour += 12 }
        if period == "am" && hour == 12 { hour = 0 }

        return (hour, minute)
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

    private func extractWifiName(from text: String) -> String? {
        guard let range = text.range(of: "wifi", options: .caseInsensitive) else { return nil }
        let prefix = text[..<range.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
        if prefix.isEmpty { return nil }
        return prefix.components(separatedBy: " ").suffix(2).joined(separator: " ")
    }

    private func extractModeName(from text: String) -> String? {
        let lowered = text.lowercased()
        guard let openRange = lowered.range(of: "open ") else { return nil }
        let slice = text[openRange.upperBound...]
        return slice.components(separatedBy: " ").prefix(2).joined(separator: " ")
    }
}
