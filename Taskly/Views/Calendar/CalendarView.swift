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
                        CalendarTaskRow(task: task, onTap: { editingTask = task })
                            .transition(.opacity)
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
    private func taskStatusColor(_ task: TaskItem) -> Color {
        if task.isCompleted { return .green }
        if task.dueDate < Date() { return .red }
        let inSevenDays = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        if task.dueDate <= inSevenDays { return .yellow }
        return .purple
    }

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
                        .fill(taskStatusColor(task))
                        .frame(width: 6, height: 6)

                    Text(task.title)
                        .font(.caption)
                        .lineLimit(1)
                        .strikethrough(task.isCompleted, color: .green)
                        .foregroundColor(task.isCompleted ? .green : .primary)
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

struct CalendarTaskRow: View {
    @EnvironmentObject var taskVM: TaskViewModel
    let task: TaskItem
    let onTap: () -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var isSwiped = false
    @State private var showConfirmation = false
    @State private var rowHeight: CGFloat = 68

    private let deleteWidth: CGFloat = 80

    private var cardOffset: CGFloat {
        let base = isSwiped ? -deleteWidth : 0
        return min(max(base + dragOffset, -deleteWidth), 0)
    }

    private var deleteOpacity: Double {
        Double(min(abs(cardOffset) / (deleteWidth * 0.5), 1.0))
    }

    private var isOverdue: Bool {
        task.dueDate < Date() && !task.isCompleted
    }

    private var isDueSoon: Bool {
        guard !task.isCompleted, task.dueDate >= Date() else { return false }
        let inSevenDays = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        return task.dueDate <= inSevenDays
    }

    private var rowBackground: Color {
        if isOverdue        { return Color.red.opacity(0.08) }
        if task.isCompleted { return Color.green.opacity(0.06) }
        if isDueSoon        { return Color.yellow.opacity(0.12) }
        return Color(.systemGray6)
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            Button {
                showConfirmation = true
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "trash.fill")
                    Text("Delete")
                        .font(.caption.bold())
                }
                .foregroundColor(.white)
                .frame(width: deleteWidth, height: rowHeight)
                .background(Color.red)
                .cornerRadius(10)
            }
            .opacity(deleteOpacity)
            .allowsHitTesting(cardOffset < 0)

            HStack(spacing: 12) {
                Button {
                    taskVM.toggleComplete(task)
                } label: {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(task.isCompleted ? .green : .gray)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .strikethrough(task.isCompleted, color: .green)
                        .foregroundColor(task.isCompleted ? .green : .primary)

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
            .background(rowBackground)
            .cornerRadius(10)
            .background(
                GeometryReader { geo in
                    Color(UIColor.systemBackground)
                        .onAppear { rowHeight = geo.size.height }
                }
            )
            .offset(x: cardOffset)
            .onTapGesture {
                if isSwiped {
                    withAnimation(.spring(response: 0.3)) {
                        isSwiped = false
                        dragOffset = 0
                    }
                } else {
                    onTap()
                }
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                    .onChanged { value in
                        let isHorizontal = abs(value.translation.width) > abs(value.translation.height)
                        if isHorizontal {
                            dragOffset = value.translation.width
                        } else {
                            if isSwiped || dragOffset != 0 {
                                withAnimation(.spring(response: 0.3)) {
                                    isSwiped = false
                                    dragOffset = 0
                                }
                            }
                        }
                    }
                    .onEnded { value in
                        let isHorizontal = abs(value.translation.width) > abs(value.translation.height)
                        withAnimation(.spring(response: 0.3)) {
                            if isHorizontal {
                                let net = (isSwiped ? -deleteWidth : 0) + value.translation.width
                                isSwiped = net < -(deleteWidth / 2)
                            }
                            dragOffset = 0
                        }
                    }
            )
        }
        .alert("Delete \"\(task.title)\"?", isPresented: $showConfirmation) {
            Button("Delete", role: .destructive) {
                withAnimation(.easeOut(duration: 0.25)) {
                    taskVM.deleteTask(task)
                }
            }
            Button("Cancel", role: .cancel) {
                withAnimation(.spring(response: 0.3)) {
                    isSwiped = false
                    dragOffset = 0
                }
            }
        } message: {
            Text("This cannot be undone.")
        }
    }
}

#Preview {
    CalendarView()
        .environmentObject(TaskViewModel())
}
