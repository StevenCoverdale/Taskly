import Foundation

struct TaskItem: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var notes: String
    var dueDate: Date
    var priority: Priority
    var category: Category
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        dueDate: Date = .now,
        priority: Priority = .medium,
        category: Category = .general,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.dueDate = dueDate
        self.priority = priority
        self.category = category
        self.isCompleted = isCompleted
    }

    enum Priority: String, CaseIterable, Codable {
        case low, medium, high
    }

    enum Category: String, CaseIterable, Codable {
        case general = "General"
        case work = "Work"
        case personal = "Personal"
        case school = "School"
        case health = "Health"
        case other = "Other"
    }
}
