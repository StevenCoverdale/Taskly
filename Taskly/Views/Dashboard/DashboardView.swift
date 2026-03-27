//
//  DashboardView.swift
//  Taskly
//
//  Created by steven coverdale on 2026-03-26.
//

import SwiftUI

struct DashboardView: View {
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
                    Text("Tasks (\(taskVM.tasks.count))")
                        .font(.title3.bold())
                        .padding(.top, 10)

                    VStack(spacing: 16) {
                        ForEach(taskVM.tasks) { task in
                            DashboardTaskCard(task: task)
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
        HStack {
            filterButton("Status")
            filterButton("Category")
            filterButton("Due")
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
