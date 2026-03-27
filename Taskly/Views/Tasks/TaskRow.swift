//
//  TaskRow.swift
//  Taskly
//
//  Created by steven coverdale on 2026-03-26.
//

import SwiftUI

struct TaskRow: View {
    let task: TaskItem

    var body: some View {
        HStack {
            Circle()
                .fill(color(for: task.priority))
                .frame(width: 10, height: 10)

            VStack(alignment: .leading) {
                Text(task.title)
                    .strikethrough(task.isCompleted)
                    .font(.headline)

                Text(task.dueDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            if task.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
    }

    func color(for priority: TaskItem.Priority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .yellow
        case .low: return .green
        }
    }
}
