//
//  CalendarWeekView.swift
//  Taskly
//
//  Created by David Rashidi on 2026-04-15.
//

import SwiftUI

struct CalendarWeekView: View {
    @EnvironmentObject var taskVM: TaskViewModel
    let weekStart: Date
    @Binding var selectedDate: Date

    private let calendar = Calendar.current

    private var weekDays: [Date] {
        (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { date in
                dayCell(date)
                    .onTapGesture { selectedDate = date }
            }
        }
    }

    private func dayCell(_ date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let tasks = taskVM.tasks(for: date)

        return VStack(spacing: 6) {
            Text(shortDay(date))
                .font(.caption)
                .foregroundColor(.secondary)

            Text("\(calendar.component(.day, from: date))")
                .font(.body)
                .fontWeight(isToday ? .bold : .regular)
                .frame(width: 32, height: 32)
                .background(
                    isSelected
                    ? Color.purple
                    : (isToday ? Color.purple.opacity(0.2) : Color.clear)
                )
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Circle())

            HStack(spacing: 3) {
                ForEach(tasks.prefix(3), id: \.id) { task in
                    Circle()
                        .fill(dotColor(task.priority))
                        .frame(width: 5, height: 5)
                }
            }
            .frame(height: 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private func shortDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private func dotColor(_ priority: TaskItem.Priority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}
