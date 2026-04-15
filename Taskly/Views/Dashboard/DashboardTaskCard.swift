import SwiftUI

struct DashboardTaskCard: View {
    @EnvironmentObject var taskVM: TaskViewModel
    let task: TaskItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                taskVM.toggleComplete(task)
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 8) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted, color: .green)
                    .foregroundColor(task.isCompleted ? .green : .primary)

                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Label(task.dueDate.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    statusBadge
                    priorityBadge
                    categoryBadge(task.category.rawValue)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardColor)
        .cornerRadius(12)
    }

    private var statusBadge: some View {
        let overdue = task.dueDate < Date() && !task.isCompleted
        let label = overdue ? "Overdue" : (task.isCompleted ? "Completed" : "Pending")
        let icon = overdue ? "clock.fill" : "checkmark.circle.fill"
        let bg: Color = overdue ? .red.opacity(0.2) : (task.isCompleted ? .green.opacity(0.2) : .gray.opacity(0.15))

        return HStack(spacing: 4) {
            Image(systemName: icon)
            Text(label)
        }
        .font(.caption)
        .padding(6)
        .background(bg)
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

    private var priorityColor: Color {
        switch task.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }

    private var cardColor: Color {
        if task.dueDate < Date() && !task.isCompleted {
            return Color.red.opacity(0.08)
        } else if task.isCompleted {
            return Color.green.opacity(0.06)
        } else {
            return Color.gray.opacity(0.05)
        }
    }
}
