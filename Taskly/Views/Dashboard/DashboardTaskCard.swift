//
//  DashboardTaskCard.swift
//  Taskly
//
//  Created by steven coverdale on 2026-03-26.
//

import SwiftUI

struct DashboardTaskCard: View {
    let task: TaskItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // TITLE
            Text(task.title)
                .font(.headline)

            // NOTES
            if !task.notes.isEmpty {
                Text(task.notes)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            // STATUS ROW
            HStack(spacing: 10) {
                statusBadge
                priorityBadge
                categoryBadge("Assignment")
                categoryBadge("Study")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardColor)
        .cornerRadius(12)
    }

    // MARK: - Badges
    private var statusBadge: some View {
        let overdue = task.dueDate < Date() && !task.isCompleted

        return HStack {
            Image(systemName: overdue ? "clock.fill" : "checkmark.circle.fill")
            Text(overdue ? "Overdue" : (task.isCompleted ? "Completed" : "Pending"))
        }
        .font(.caption)
        .padding(6)
        .background(overdue ? Color.red.opacity(0.2) : Color.green.opacity(0.2))
        .cornerRadius(8)
    }

    private var priorityBadge: some View {
        Text(task.priority.rawValue.capitalized)
            .font(.caption)
            .padding(6)
            .background(priorityColor.opacity(0.2))
            .cornerRadius(8)
    }

    private func categoryBadge(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .padding(6)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(8)
    }

    // MARK: - Colors
    private var priorityColor: Color {
        switch task.priority {
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .green
        }
    }

    private var cardColor: Color {
        let overdue = task.dueDate < Date() && !task.isCompleted
        return overdue ? Color.red.opacity(0.1) : Color.gray.opacity(0.05)
    }
}

