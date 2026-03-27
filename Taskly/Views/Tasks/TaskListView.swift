//
//  TaskListView.swift
//  Taskly
//
//  Created by steven coverdale on 2026-03-26.
//

import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var taskVM: TaskViewModel
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(taskVM.tasks) { task in
                    NavigationLink {
                        EditTaskView(task: task)
                    } label: {
                        TaskRow(task: task)
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { taskVM.tasks[$0] }.forEach(taskVM.deleteTask)
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                Button {
                    showAdd = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
            .sheet(isPresented: $showAdd) {
                AddTaskView()
            }
        }
    }
}
