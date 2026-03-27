//
//  Task.swift
//  Taskly
//
//  Created by steven coverdale on 2026-03-26.
//

import Foundation

struct TaskItem: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var notes: String
    var dueDate: Date
    var priority: Priority
    var isCompleted: Bool = false

    enum Priority: String, CaseIterable {
        case low, medium, high
    }
}
