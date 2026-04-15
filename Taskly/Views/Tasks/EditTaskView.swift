import SwiftUI

struct EditTaskView: View {
    @EnvironmentObject var taskVM: TaskViewModel
    @Environment(\.dismiss) var dismiss

    @State var task: TaskItem

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $task.title)
                TextField("Notes", text: $task.notes)

                DatePicker("Due Date & Time", selection: $task.dueDate, displayedComponents: [.date, .hourAndMinute])

                Picker("Priority", selection: $task.priority) {
                    ForEach(TaskItem.Priority.allCases, id: \.self) { p in
                        Text(p.rawValue.capitalized)
                    }
                }

                Picker("Category", selection: $task.category) {
                    ForEach(TaskItem.Category.allCases, id: \.self) { c in
                        Text(c.rawValue)
                    }
                }

                Toggle("Completed", isOn: $task.isCompleted)
            }
            .navigationTitle("Edit Task")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        taskVM.updateTask(task)
                        dismiss()
                    }
                    .disabled(task.title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
