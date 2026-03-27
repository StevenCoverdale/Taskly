//
//  TasklyApp.swift
//  Taskly
//
//  Created by steven coverdale on 2026-03-26.
//

import SwiftUI

@main
struct TasklyApp: App {
    @StateObject private var taskVM = TaskViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(taskVM)
        }
    }
}
