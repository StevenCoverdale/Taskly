//
//  CalendarMonthGrid.swift
//  Taskly
//
//  Created by steven coverdale on 2026-03-26.
//

import SwiftUI

struct CalendarMonthGrid: View {
    let month: Date
    @Binding var selectedDate: Date
    let tasks: [TaskItem]

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack(spacing: 8) {

            // Weekday labels
            HStack {
                ForEach(["Mon","Tue","Wed","Thu","Fri","Sat","Sun"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(generateMonthDays(), id: \.self) { date in
                    VStack(spacing: 4) {

                        // DATE NUMBER
                        Text("\(Calendar.current.component(.day, from: date))")
                            .font(.body)
                            .frame(maxWidth: .infinity)
                            .padding(6)
                            .background(isSameDay(date, selectedDate) ? Color.blue.opacity(0.2) : .clear)
                            .clipShape(Circle())

                        // DOTS FOR TASKS
                        let dayTasks = tasksFor(date)
                        HStack(spacing: 3) {
                            ForEach(dayTasks.prefix(3), id: \.id) { task in
                                Circle()
                                    .fill(color(for: task))
                                    .frame(width: 6, height: 6)
                            }
                        }

                        // LABELS (UI M..., Test 1, etc.)
                        if let first = dayTasks.first {
                            Text(first.title.prefix(5) + "…")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    .onTapGesture {
                        selectedDate = date
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Helpers

    func generateMonthDays() -> [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: month)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!

        return range.compactMap { day -> Date in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
        }
    }

    func tasksFor(_ date: Date) -> [TaskItem] {
        tasks.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: date) }
    }

    func color(for task: TaskItem) -> Color {
        switch task.priority {
        case .high: return .yellow
        case .medium: return .blue
        case .low: return .green
        }
    }

    func isSameDay(_ d1: Date, _ d2: Date) -> Bool {
        Calendar.current.isDate(d1, inSameDayAs: d2)
    }
}
