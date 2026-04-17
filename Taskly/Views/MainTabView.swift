import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var taskVM: TaskViewModel

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Tasks", systemImage: "list.bullet.rectangle") }
                .badge(overdueCount > 0 ? overdueCount : 0)

            CalendarView()
                .tabItem { Label("Calendar", systemImage: "calendar") }
        }
    }

    private var overdueCount: Int {
        taskVM.tasks.filter { $0.dueDate < Date() && !$0.isCompleted }.count
    }
}
