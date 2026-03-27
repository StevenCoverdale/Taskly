//
//  CalendarTaskCard.swift
//  Taskly
//
//  Created by steven coverdale on 2026-03-26.
//

import SwiftUI

struct CalendarTaskCard: View {
    let task: TaskItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(task.title)
                .font(.headline)

            HStack(spacing: 10) {
                statusBadge
                priorityBadge
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }

    private var statusBadge: some View {
        let overdue = task.dueDate < Date() && !task.isCompleted

        return HStack {
            Image(systemName: overdue ? "clock.fill" : "checkmark.circle.fill")
            Text(overdue ? "In Progress" : (task.isCompleted ? "Completed" : "Pending"))
        }
        .font(.caption)
        .padding(6)
        .background(overdue ? Color.yellow.opacity(0.2) : Color.green.opacity(0.2))
        .cornerRadius(8)
    }

    private var priorityBadge: some View {
        Text(task.priority.rawValue.capitalized)
            .font(.caption)
            .padding(6)
            .background(priorityColor.opacity(0.2))
            .cornerRadius(8)
    }

    private var priorityColor: Color {
        switch task.priority {
        case .high: return .yellow
        case .medium: return .blue
        case .low: return .green
        }
    }
}
