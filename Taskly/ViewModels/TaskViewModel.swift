import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = [] {
        didSet { save() }
    }

    private let storageKey = "taskly_saved_tasks"

    init() {
        load()
        if tasks.isEmpty {
            tasks = [
                TaskItem(title: "Finish Prototype", notes: "Due tomorrow", dueDate: .now, priority: .high, category: .school),
                TaskItem(title: "Buy groceries", notes: "", dueDate: .now.addingTimeInterval(86400), priority: .medium, category: .personal)
            ]
        }
    }

    func tasks(for date: Date) -> [TaskItem] {
        tasks.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: date) }
    }

    func addTask(_ task: TaskItem) {
        tasks.append(task)
    }

    func updateTask(_ task: TaskItem) {
        if let i = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[i] = task
        }
    }

    func deleteTask(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
    }

    func toggleComplete(_ task: TaskItem) {
        var updated = task
        updated.isCompleted.toggle()
        updateTask(updated)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([TaskItem].self, from: data)
        else { return }
        tasks = decoded
    }
}
