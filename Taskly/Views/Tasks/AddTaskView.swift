//
//  AddTaskView.swift
//  Taskly
//
//  Created by steven coverdale on 2026-03-26.
//

import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var taskVM: TaskViewModel
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var notes = ""
    @State private var dueDate = Date()
    @State private var priority: TaskItem.Priority = .medium
    @State private var category: TaskItem.Category = .general

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextField("Notes", text: $notes)

                DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)

                Picker("Priority", selection: $priority) {
                    ForEach(TaskItem.Priority.allCases, id: \.self) { p in
                        Text(p.rawValue.capitalized)
                    }
                }
                Picker("Category", selection: $category) {
                    ForEach(TaskItem.Category.allCases, id: \.self) { c in
                        Text(c.rawValue)
                    }
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newTask = TaskItem(
                            title: title,
                            notes: notes,
                            dueDate: dueDate,
                            priority: priority,
                            category: category
                        )
                        taskVM.addTask(newTask)
                        dismiss()
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
