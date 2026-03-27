//
//  MainTabView.swift
//  Taskly
//
//  Created by steven coverdale on 2026-03-26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Tasks", systemImage: "list.bullet.rectangle") }

            CalendarView()
                .tabItem { Label("Calendar", systemImage: "calendar") }
        }

    }
}
