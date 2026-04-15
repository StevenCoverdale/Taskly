//
//  DashboardView.swift
//  Taskly
//
//  Created by steven coverdale on 2026-03-26.
//

import SwiftUI

enum TaskFilter: String, CaseIterable {
    case all = "All"
    case pending = "Pending"
    case completed = "Done"
    case overdue = "Overdue"
}

struct DashboardView: View {
    @State private var activeFilter: TaskFilter = .all

    var filteredTasks: [TaskItem] {
        switch activeFilter {
        case .all:       return taskVM.tasks
        case .pending:   return taskVM.tasks.filter { !$0.isCompleted }
        case .completed: return taskVM.tasks.filter { $0.isCompleted }
        case .overdue:   return taskVM.tasks.filter { $0.dueDate < Date() && !$0.isCompleted }
        }
    }
    @EnvironmentObject var taskVM: TaskViewModel
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // HEADER
                    HStack {
                        Text("Taskly")
                            .font(.largeTitle.bold())

                        Spacer()

                        Button {
                            showAdd = true
                        } label: {
                            Text("+ New Task")
                                .font(.headline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }

                    // STATS GRID
                    statsSection

                    // FILTER BUTTONS
                    filterSection

                    // TASK LIST
                    Text("Tasks (\(filteredTasks.count))")
                        .font(.title3.bold())
                        .padding(.top, 10)

                    if filteredTasks.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "tray")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary.opacity(0.4))
                            Text(activeFilter == .all ? "No tasks yet" : "No \(activeFilter.rawValue.lowercased()) tasks")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            if activeFilter == .all {
                                Button("Add your first task") { showAdd = true }
                                    .buttonStyle(.borderedProminent)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 50)
                    } else {
                        VStack(spacing: 16) {
                            ForEach(filteredTasks) { task in
                                DashboardTaskCard(task: task)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAdd) {
                AddTaskView()
            }
        }
    }

    // MARK: - Stats Section
    private var statsSection: some View {
        let total = taskVM.tasks.count
        let completed = taskVM.tasks.filter { $0.isCompleted }.count
        let overdue = taskVM.tasks.filter { $0.dueDate < Date() && !$0.isCompleted }.count
        let dueSoon = taskVM.tasks.filter { !$0.isCompleted && Calendar.current.isDateInTomorrow($0.dueDate) }.count

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {

            statCard(title: "Total Tasks", value: total, color: .purple)
            statCard(title: "Completed", value: completed, color: .green)
            statCard(title: "Overdue", value: overdue, color: .red)
            statCard(title: "Due Soon", value: dueSoon, color: .orange)
        }
    }

    // MARK: - Filter Section
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TaskFilter.allCases, id: \.self) { filter in
                    Button(filter.rawValue) {
                        activeFilter = filter
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(activeFilter == filter ? Color.blue : Color.gray.opacity(0.15))
                    .foregroundColor(activeFilter == filter ? .white : .primary)
                    .cornerRadius(10)
                    .animation(.easeInOut(duration: 0.15), value: activeFilter)
                }
            }
        }
    }

    // MARK: - Components
    private func statCard(title: String, value: Int, color: Color) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))

            Text("\(value)")
                .font(.title.bold())
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(color)
        .cornerRadius(12)
    }

    private func filterButton(_ title: String) -> some View {
        Text(title)
            .font(.subheadline)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(10)
    }
}
