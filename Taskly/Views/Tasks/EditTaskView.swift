//
//  EditTaskView.swift
//  Taskly
//
//  Created by steven coverdale on 2026-03-26.
//

import SwiftUI

struct EditTaskView: View {
    @EnvironmentObject var taskVM: TaskViewModel
    @Environment(\.dismiss) var dismiss

    @State var task: TaskItem

    var body: some View {
        Form {
            TextField("Title", text: $task.title)
            TextField("Notes", text: $task.notes)

            DatePicker("Due Date", selection: $task.dueDate, displayedComponents: .date)

            Picker("Priority", selection: $task.priority) {
                ForEach(TaskItem.Priority.allCases, id: \.self) { p in
                    Text(p.rawValue.capitalized)
                }
            }

            Toggle("Completed", isOn: $task.isCompleted)
        }
        .navigationTitle("Edit Task")
        .toolbar {
            Button("Save") {
                taskVM.updateTask(task)
                dismiss()
            }
        }
    }
}
