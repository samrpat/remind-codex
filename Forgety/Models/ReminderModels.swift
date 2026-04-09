import Foundation
import CoreLocation

enum ReminderStatus: String, Codable, CaseIterable {
    case active
    case completed
    case archived
}

enum Priority: Int, Codable, CaseIterable, Identifiable {
    case low = 0
    case medium = 1
    case high = 2

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

enum RepeatFrequency: String, Codable, CaseIterable, Identifiable {
    case never
    case hourly
    case daily
    case weekly
    case monthly
    case yearly

    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }
}

struct ReminderRepeatRule: Codable, Hashable {
    var frequency: RepeatFrequency
    var interval: Int

    static let none = ReminderRepeatRule(frequency: .never, interval: 1)
}

struct ReminderAlert: Codable, Hashable, Identifiable {
    let id: UUID
    var offsetMinutes: Int

    init(id: UUID = UUID(), offsetMinutes: Int) {
        self.id = id
        self.offsetMinutes = offsetMinutes
    }
}

enum ReminderTrigger: Codable, Hashable {
    case time(Date)
    case location(LocationTrigger)
    case wifi(String)
    case appMode(String)
    case arrival(LocationTrigger)
    case departure(LocationTrigger)
    case none
}

struct LocationTrigger: Codable, Hashable {
    let label: String
    let latitude: Double?
    let longitude: Double?

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct Subtask: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var isDone: Bool
    var children: [Subtask]

    init(id: UUID = UUID(), title: String, isDone: Bool = false, children: [Subtask] = []) {
        self.id = id
        self.title = title
        self.isDone = isDone
        self.children = children
    }
}

struct ReminderItem: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var notes: String?
    var url: URL?
    var categoryID: UUID
    var listName: String
    var createdAt: Date
    var dueDate: Date?
    var startDate: Date?
    var trigger: ReminderTrigger
    var status: ReminderStatus
    var priority: Priority
    var flagged: Bool
    var allDay: Bool
    var tags: [String]
    var subtasks: [Subtask]
    var repeatRule: ReminderRepeatRule
    var alerts: [ReminderAlert]
    var assignedTo: String?
    var lastNotifiedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        notes: String? = nil,
        url: URL? = nil,
        categoryID: UUID,
        listName: String = "Reminders",
        createdAt: Date = .now,
        dueDate: Date? = nil,
        startDate: Date? = nil,
        trigger: ReminderTrigger = .none,
        status: ReminderStatus = .active,
        priority: Priority = .medium,
        flagged: Bool = false,
        allDay: Bool = false,
        tags: [String] = [],
        subtasks: [Subtask] = [],
        repeatRule: ReminderRepeatRule = .none,
        alerts: [ReminderAlert] = [ReminderAlert(offsetMinutes: 0)],
        assignedTo: String? = nil,
        lastNotifiedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.url = url
        self.categoryID = categoryID
        self.listName = listName
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.startDate = startDate
        self.trigger = trigger
        self.status = status
        self.priority = priority
        self.flagged = flagged
        self.allDay = allDay
        self.tags = tags
        self.subtasks = subtasks
        self.repeatRule = repeatRule
        self.alerts = alerts
        self.assignedTo = assignedTo
        self.lastNotifiedAt = lastNotifiedAt
    }
}

struct ReminderCategory: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var icon: String
    var tintHex: String
    var isSystem: Bool

    init(id: UUID = UUID(), name: String, icon: String, tintHex: String, isSystem: Bool = false) {
        self.id = id
        self.name = name
        self.icon = icon
        self.tintHex = tintHex
        self.isSystem = isSystem
    }
}

struct CompletionAnalytics: Codable {
    var dayCompletionCount: Int
    var weekCompletionCount: Int
    var streakDays: Int
}

struct AppSettings: Codable, Hashable {
    var smartParsingEnabled: Bool = true
    var voiceQuickAddEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var smartRepeatEnabled: Bool = true
    var showBadgeCount: Bool = true
    var defaultPriority: Priority = .medium
    var defaultListName: String = "Reminders"
    var defaultRepeat: RepeatFrequency = .never
    var iCloudSyncEnabled: Bool = false
    var locationTriggersEnabled: Bool = true
    var wifiTriggersEnabled: Bool = true
    var appModeTriggersEnabled: Bool = true
}
