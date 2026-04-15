//
//  TaskViewModel.swift
//  Taskly
//
//  Created by steven coverdale on 2026-03-26.
//

import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var tasks: [TaskItem] = [
        TaskItem(title: "Finish Prototype", notes: "Due tomorrow", dueDate: .now, priority: .high, category: .school),
        TaskItem(title: "Buy groceries", notes: "", dueDate: .now.addingTimeInterval(86400), priority: .medium, category: .personal)
    ]
    
    func tasks(for date: Date) -> [TaskItem] {
        tasks.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: date) }
    }

    func addTask(_ task: TaskItem) {
        tasks.append(task)
    }

    func updateTask(_ task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }

    func deleteTask(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
    }
}
