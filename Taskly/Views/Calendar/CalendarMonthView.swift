//
//  CalendarMonthView.swift
//  Taskly
//
//  Created by steven coverdale on 2026-03-26.
//

import SwiftUI

struct CalendarMonthView: View {
    @EnvironmentObject var taskVM: TaskViewModel
    @State private var selectedDate = Date()

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack(spacing: 12) {
            Text(selectedDate.formatted(.dateTime.year().month()))
                .font(.title2.bold())

            HStack {
                ForEach(["Sun","Mon","Tue","Wed","Thu","Fri","Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(generateMonthDays(), id: \.id) { day in
                    VStack(spacing: 4) {
                        Text("\(Calendar.current.component(.day, from: day.date))")
                            .frame(maxWidth: .infinity)
                            .padding(6)
                            .background(isSameDay(day.date, selectedDate) ? Color.blue.opacity(0.2) : .clear)
                            .clipShape(Circle())

                        HStack(spacing: 3) {
                            ForEach(day.tasks.prefix(3), id: \.id) { task in
                                Circle()
                                    .fill(color(for: task))
                                    .frame(width: 6, height: 6)
                            }
                        }
                    }
                    .onTapGesture {
                        selectedDate = day.date
                    }
                }
            }
        }
        .padding()
    }

    func generateMonthDays() -> [CalendarDay] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: selectedDate)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!

        return range.compactMap { day -> CalendarDay in
            let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
            let tasks = taskVM.tasks.filter { calendar.isDate($0.dueDate, inSameDayAs: date) }
            return CalendarDay(date: date, tasks: tasks)
        }
    }

    func color(for task: TaskItem) -> Color {
        switch task.priority {
        case .high: return .red
        case .medium: return .yellow
        case .low: return .green
        }
    }

    func isSameDay(_ d1: Date, _ d2: Date) -> Bool {
        Calendar.current.isDate(d1, inSameDayAs: d2)
    }
}

struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
    let tasks: [TaskItem]
}
