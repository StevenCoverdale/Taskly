import SwiftUI

enum TaskFilter: String, CaseIterable {
    case all = "All"
    case pending = "Pending"
    case completed = "Done"
    case overdue = "Overdue"
}

enum TaskSort: String, CaseIterable {
    case dueDate = "Due Date"
    case priority = "Priority"
    case title = "Title"
}

struct DashboardView: View {
    @EnvironmentObject var taskVM: TaskViewModel
    @State private var showAdd = false
    @State private var editingTask: TaskItem? = nil
    @State private var activeFilter: TaskFilter = .all
    @State private var activeSort: TaskSort = .dueDate
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool

    var filteredTasks: [TaskItem] {
        switch activeFilter {
        case .all:       return taskVM.tasks
        case .pending:   return taskVM.tasks.filter { !$0.isCompleted }
        case .completed: return taskVM.tasks.filter { $0.isCompleted }
        case .overdue:   return taskVM.tasks.filter { $0.dueDate < Date() && !$0.isCompleted }
        }
    }

    var displayedTasks: [TaskItem] {
        var base = filteredTasks
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            base = base.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.notes.localizedCaseInsensitiveContains(searchText) ||
                $0.category.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        let sorted: [TaskItem]
        switch activeSort {
        case .dueDate:
            sorted = base.sorted { $0.dueDate < $1.dueDate }
        case .priority:
            let rank: [TaskItem.Priority: Int] = [.high: 0, .medium: 1, .low: 2]
            sorted = base.sorted { rank[$0.priority, default: 1] < rank[$1.priority, default: 1] }
        case .title:
            sorted = base.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }
        return sorted.sorted { !$0.isCompleted && $1.isCompleted }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

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

                    HStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            TextField("Search tasks, categories...", text: $searchText)
                                .textFieldStyle(.plain)
                                .focused($isSearchFocused)
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)

                        if isSearchFocused {
                            Button("Cancel") {
                                searchText = ""
                                isSearchFocused = false
                            }
                            .foregroundColor(.blue)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: isSearchFocused)

                    statsSection

                    filterSection

                    HStack {
                        Text("Sort:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Picker("Sort", selection: $activeSort) {
                            ForEach(TaskSort.allCases, id: \.self) { s in
                                Text(s.rawValue).tag(s)
                            }
                        }
                        .pickerStyle(.menu)
                        Spacer()
                    }

                    Text("Tasks (\(displayedTasks.count))")
                        .font(.title3.bold())
                        .padding(.top, 10)

                    if displayedTasks.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "tray")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary.opacity(0.4))
                            Text(searchText.isEmpty
                                 ? (activeFilter == .all ? "No tasks yet" : "No \(activeFilter.rawValue.lowercased()) tasks")
                                 : "No results for \"\(searchText)\"")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            if activeFilter == .all && searchText.isEmpty {
                                Button("Add your first task") { showAdd = true }
                                    .buttonStyle(.borderedProminent)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 50)
                    } else {
                        VStack(spacing: 16) {
                            ForEach(displayedTasks) { task in
                                TaskCardRow(task: task, onTap: { editingTask = task })
                                    .transition(.opacity)
                            }
                        }
                    }
                }
                .padding()
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationBarHidden(true)
            .sheet(isPresented: $showAdd) {
                AddTaskView()
            }
            .sheet(item: $editingTask) { task in
                EditTaskView(task: task)
            }
        }
    }

    private var statsSection: some View {
        let total = taskVM.tasks.count
        let completed = taskVM.tasks.filter { $0.isCompleted }.count
        let overdue = taskVM.tasks.filter { $0.dueDate < Date() && !$0.isCompleted }.count
        let dueSoon = taskVM.tasks.filter {
            guard !$0.isCompleted else { return false }
            let inSevenDays = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
            return $0.dueDate >= Date() && $0.dueDate <= inSevenDays
        }.count

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            statCard(title: "Total Tasks", value: total, color: .purple)
            statCard(title: "Completed", value: completed, color: .green)
            statCard(title: "Overdue", value: overdue, color: .red)
            statCard(title: "Next 7 Days", value: dueSoon, color: .orange)
        }
    }

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
}

struct TaskCardRow: View {
    @EnvironmentObject var taskVM: TaskViewModel
    let task: TaskItem
    let onTap: () -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var isSwiped = false
    @State private var showConfirmation = false

    private let deleteWidth: CGFloat = 80

    private var cardOffset: CGFloat {
        let base = isSwiped ? -deleteWidth : 0
        return min(max(base + dragOffset, -deleteWidth), 0)
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
                .frame(width: deleteWidth)
                .frame(maxHeight: .infinity)
                .background(Color.red)
                .cornerRadius(12)
            }
            .opacity(cardOffset < 0 ? 1 : 0)
            .allowsHitTesting(cardOffset < 0)

            DashboardTaskCard(task: task)
                .background(Color(UIColor.systemBackground))
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
                                // vertical drag — close swipe and let ScrollView take over
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
