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

        if let date = detectDate(in: input) {
            trigger = .time(date)
        }

        stripped = stripped
            .replacingOccurrences(of: "remind me to", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "remind me", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return ParsedReminderInput(cleanedTitle: stripped.isEmpty ? input : stripped, categoryHint: categoryHint, trigger: trigger)
    }

    private func detectDate(in text: String) -> Date? {
        guard let detector else { return nil }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let result = detector.firstMatch(in: text, options: [], range: range)
        return result?.date
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
