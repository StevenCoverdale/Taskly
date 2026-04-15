import SwiftUI

struct DashboardTaskCard: View {
    @EnvironmentObject var taskVM: TaskViewModel
    let task: TaskItem

    private var isOverdue: Bool {
        task.dueDate < Date() && !task.isCompleted
    }

    private var isDueSoon: Bool {
        guard !task.isCompleted, task.dueDate >= Date() else { return false }
        let inSevenDays = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        return task.dueDate <= inSevenDays
    }

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
        let label = isOverdue ? "Overdue" : (task.isCompleted ? "Completed" : (isDueSoon ? "Due Soon" : "Pending"))
        let icon = isOverdue ? "clock.fill" : "checkmark.circle.fill"
        let bg: Color = isOverdue ? .red.opacity(0.2) : (task.isCompleted ? .green.opacity(0.2) : (isDueSoon ? .yellow.opacity(0.3) : .gray.opacity(0.15)))

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
        if isOverdue       { return Color.red.opacity(0.08) }
        if task.isCompleted { return Color.green.opacity(0.06) }
        if isDueSoon       { return Color.yellow.opacity(0.12) }
        return Color.gray.opacity(0.05)
    }
}
