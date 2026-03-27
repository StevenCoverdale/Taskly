//
//  CalendarWeekView.swift
//  Taskly
//
//  Created by steven coverdale on 2026-03-26.
//

import SwiftUI

struct FilterView: View {
    @State private var showCompleted = true
    @State private var priority: TaskItem.Priority? = nil

    var body: some View {
        NavigationStack {
            Form {
                Toggle("Show Completed", isOn: $showCompleted)

                Picker("Priority", selection: $priority) {
                    Text("Any").tag(TaskItem.Priority?.none)
                    ForEach(TaskItem.Priority.allCases, id: \.self) { p in
                        Text(p.rawValue.capitalized).tag(Optional(p))
                    }
                }
            }
            .navigationTitle("Filters")
        }
    }
}
