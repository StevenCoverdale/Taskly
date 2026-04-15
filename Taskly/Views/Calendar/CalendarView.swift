import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var taskVM: TaskViewModel

    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date = Date()
    @State private var showAdd = false
    @State private var editingTask: TaskItem? = nil
    @State private var isWeekMode = false

    private let calendar = Calendar.current

    private var weekStart: Date {
        calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)) ?? selectedDate
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { showAdd = true }) {
                    Text("+ New Task")
                        .font(.headline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 14)
                        .background(Color.purple.opacity(0.15))
                        .foregroundColor(.purple)
                        .cornerRadius(10)
                }

                Spacer()

                HStack(spacing: 12) {
                    Button("Week") { isWeekMode.toggle() }
                        .font(.subheadline)
                        .foregroundColor(isWeekMode ? .purple : .gray)
                        .fontWeight(isWeekMode ? .semibold : .regular)

                    Button("Today") {
                        selectedDate = Date()
                        currentMonth = Date()
                    }
                    .font(.subheadline)
                    .foregroundColor(.purple)
                }
            }
            .padding(.vertical, 10)

            HStack {
                Button { changeMonth(-1) } label: {
                    Image(systemName: "chevron.left")
                }

                Spacer()

                Text(monthYearString(from: currentMonth))
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button { changeMonth(1) } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.vertical, 8)

            if isWeekMode {
                CalendarWeekView(weekStart: weekStart, selectedDate: $selectedDate)
                    .padding(.vertical, 8)
            } else {
                HStack {
                    ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                        Text(day)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 4)

                let days = generateDays(for: currentMonth)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                    ForEach(days, id: \.self) { date in
                        dayCell(date)
                            .onTapGesture { selectedDate = date }
                    }
                }
                .padding(.bottom, 12)
            }

            Divider().padding(.vertical, 8)

            VStack(alignment: .leading, spacing: 12) {
                Text("Tasks for \(formattedDate(selectedDate))")
                    .font(.headline)

                let tasks = taskVM.tasks(for: selectedDate)

                if tasks.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 36))
                            .foregroundColor(.secondary.opacity(0.4))
                        Text("No tasks on \(formattedDate(selectedDate))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                } else {
                    ForEach(tasks) { task in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(task.title)
                                    .font(.body)
                                    .fontWeight(.medium)

                                HStack {
                                    Text(task.priority.rawValue.capitalized)
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.purple.opacity(0.2))
                                        .cornerRadius(6)

                                    if !task.notes.isEmpty {
                                        Text("In Progress")
                                            .font(.caption)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(6)
                                    }
                                }
                            }

                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .contentShape(Rectangle())
                        .onTapGesture { editingTask = task }
                    }
                }
            }
            .sheet(item: $editingTask) { task in
                EditTaskView(task: task)
            }

            Spacer()
        }
        .padding(.horizontal)
        .sheet(isPresented: $showAdd) {
            AddTaskView(prefilledDate: selectedDate)
        }
    }
}

extension CalendarView {
    private func dayCell(_ date: Date) -> some View {
        let tasks = taskVM.tasks(for: date)
        let topTasks = Array(tasks.prefix(2))
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)

        return VStack(alignment: .leading, spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(.body)
                .fontWeight(isToday(date) ? .bold : .regular)
                .foregroundColor(isSameMonth(date, as: currentMonth) ? .primary : .gray)

            ForEach(topTasks) { task in
                HStack(spacing: 4) {
                    Circle()
                        .fill(.purple)
                        .frame(width: 6, height: 6)

                    Text(task.title)
                        .font(.caption)
                        .lineLimit(1)
                }
            }
        }
        .padding(6)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            isSelected
            ? RoundedRectangle(cornerRadius: 8).fill(Color.purple.opacity(0.15))
            : nil
        )
    }
}

extension CalendarView {
    private func changeMonth(_ value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    private func isSameMonth(_ date: Date, as month: Date) -> Bool {
        calendar.isDate(date, equalTo: month, toGranularity: .month)
    }

    private func generateDays(for month: Date) -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start)
        else { return [] }

        return (0..<42).compactMap {
            calendar.date(byAdding: .day, value: $0, to: firstWeek.start)
        }
    }
}

#Preview {
    CalendarView()
        .environmentObject(TaskViewModel())
}
