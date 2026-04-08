import Foundation
import CoreLocation

enum ReminderStatus: String, Codable, CaseIterable {
    case active
    case completed
    case archived
}

enum Priority: Int, Codable, CaseIterable {
    case low = 0
    case medium = 1
    case high = 2
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
    var categoryID: UUID
    var createdAt: Date
    var trigger: ReminderTrigger
    var status: ReminderStatus
    var priority: Priority
    var subtasks: [Subtask]
    var lastNotifiedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        notes: String? = nil,
        categoryID: UUID,
        createdAt: Date = .now,
        trigger: ReminderTrigger = .none,
        status: ReminderStatus = .active,
        priority: Priority = .medium,
        subtasks: [Subtask] = [],
        lastNotifiedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.categoryID = categoryID
        self.createdAt = createdAt
        self.trigger = trigger
        self.status = status
        self.priority = priority
        self.subtasks = subtasks
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
