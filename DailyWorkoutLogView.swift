//
//  DailyWorkoutLogView.swift
//  WorkoutApp
//
//  Created by cmStudent on 2024/10/22.
//

import SwiftUI

struct DailyWorkoutView: View {
    @StateObject private var logManager = WorkoutLogManager.shared
    @State private var expandedWeek: Date? // Tracks the expanded week for toggling

    private let calendar = Calendar.current

    var body: some View {
        VStack(alignment: .leading) { // Align all content to the leading edge (left)
            Text("週間ワークアウト履歴") // Translated to Japanese
                .font(.title)
                .padding()

            ScrollView {
                VStack(spacing: 16) {
                    // Group logs by weeks
                    let weeklyGroupedLogs = Dictionary(grouping: logManager.logs, by: { getWeekStart(for: $0.date) })

                    // Iterate over each week's logs
                    ForEach(weeklyGroupedLogs.keys.sorted(by: >), id: \.self) { weekStartDate in
                        let weekLogs = weeklyGroupedLogs[weekStartDate] ?? []

                        // Create a button/tab for each week
                        Button(action: {
                            expandedWeek = (expandedWeek == weekStartDate) ? nil : weekStartDate
                        }) {
                            HStack {
                                Text("\(formattedDate(weekStartDate))の週") // Translated to Japanese
                                    .font(.headline)
                                Spacer()
                                Image(systemName: expandedWeek == weekStartDate ? "chevron.down" : "chevron.right")
                                    .foregroundColor(.purple)
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        }

                        // Show the logs for each day in the selected week if expanded
                        if expandedWeek == weekStartDate {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(getDaysInWeek(for: weekStartDate), id: \.self) { day in
                                    let dailyLogs = weekLogs.filter { calendar.isDate($0.date, inSameDayAs: day) }

                                    if !dailyLogs.isEmpty {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(formattedDate(day))
                                                .font(.subheadline)
                                                .foregroundColor(.purple)

                                            // Create a styled box for the workout
                                            VStack(spacing: 8) {
                                                ForEach(dailyLogs, id: \.self) { log in
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Text(log.exerciseName)
                                                            .font(.headline)
                                                            .padding(.bottom, 2)
                                                        Text("セット: \(log.sets)   レップ: \(log.reps)") // Translated to Japanese
                                                        Text("重量: \(log.weight, specifier: "%.1f") kg") // Translated to Japanese
                                                    }
                                                    .padding()
                                                    .background(Color(UIColor.secondarySystemBackground))
                                                    .cornerRadius(10)
                                                    .shadow(radius: 5)
                                                }
                                            }
                                            .padding(.leading) // Add leading padding to the box for better alignment
                                            .padding(.bottom) // Add bottom padding to separate from the next day
                                        }
                                        .padding(.leading) // Left padding for the daily logs
                                    }
                                }
                            }
                            .padding(.leading) // Left padding for the expanded week's content
                        }
                    }
                }
                .padding()
            }
        }
    }


    
    // Helper function to get the start of the week for a given date
    private func getWeekStart(for date: Date) -> Date {
        calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) ?? date
    }

    // Helper function to get all dates in the week of a given start date
    private func getDaysInWeek(for weekStartDate: Date) -> [Date] {
        (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStartDate) }
    }

    // Helper function to format dates
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

//struct DailyWorkoutView: View {
//    @StateObject private var logManager = WorkoutLogManager.shared
//    @State private var expandedWeek: Date? // Tracks the expanded week for toggling
//    
//    private let calendar = Calendar.current
//
//    var body: some View {
//        VStack {
//            Text("Weekly Workout History")
//                .font(.title)
//                .padding()
//            
//            ScrollView {
//                VStack(spacing: 16) {
//                    // Group logs by weeks
//                    let weeklyGroupedLogs = Dictionary(grouping: logManager.logs, by: { getWeekStart(for: $0.date) })
//                    
//                    // Iterate over each week's logs
//                    ForEach(weeklyGroupedLogs.keys.sorted(by: >), id: \.self) { weekStartDate in
//                        let weekLogs = weeklyGroupedLogs[weekStartDate] ?? []
//                        
//                        // Create a button/tab for each week
//                        Button(action: {
//                            expandedWeek = (expandedWeek == weekStartDate) ? nil : weekStartDate
//                        }) {
//                            HStack {
//                                Text("Week of \(formattedDate(weekStartDate))")
//                                    .font(.headline)
//                                Spacer()
//                                Image(systemName: expandedWeek == weekStartDate ? "chevron.down" : "chevron.right")
//                                    .foregroundColor(.purple)
//                            }
//                            .padding()
//                            .background(Color(UIColor.systemGray6))
//                            .cornerRadius(10)
//                            .shadow(radius: 5)
//                        }
//                        
//                        // Show the logs for each day in the selected week if expanded
//                        if expandedWeek == weekStartDate {
//                            VStack(alignment: .leading, spacing: 12) {
//                                ForEach(getDaysInWeek(for: weekStartDate), id: \.self) { day in
//                                    let dailyLogs = weekLogs.filter { calendar.isDate($0.date, inSameDayAs: day) }
//                                    
//                                    if !dailyLogs.isEmpty {
//                                        VStack(alignment: .leading, spacing: 8) {
//                                            Text(formattedDate(day))
//                                                .font(.subheadline)
//                                                .foregroundColor(.purple)
//                                            
//                                            ForEach(dailyLogs, id: \.self) { log in
//                                                // Display workout entry in a styled box
//                                                VStack(alignment: .leading, spacing: 4) {
//                                                    Text(log.exerciseName)
//                                                        .font(.headline)
//                                                        .padding(.bottom, 2)
//                                                    Text("Sets: \(log.sets)   Reps: \(log.reps)")
//                                                    Text("Weight: \(log.weight, specifier: "%.1f") kg")
//                                                }
//                                                .padding()
//                                                .background(Color(UIColor.secondarySystemBackground))
//                                                .cornerRadius(10)
//                                                .shadow(radius: 5)
//                                            }
//                                        }
//                                        .padding(.leading)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//                .padding()
//            }
//        }
//    }
//    
//    // Helper function to get the start of the week for a given date
//    private func getWeekStart(for date: Date) -> Date {
//        calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) ?? date
//    }
//
//    // Helper function to get all dates in the week of a given start date
//    private func getDaysInWeek(for weekStartDate: Date) -> [Date] {
//        (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStartDate) }
//    }
//
//    // Helper function to format dates
//    private func formattedDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        return formatter.string(from: date)
//    }
//}
//struct DailyWorkoutView: View {
//    @StateObject private var logManager = WorkoutLogManager.shared
//    var date: Date
//
//    var body: some View {
//        VStack {
//            Text("Daily Workout History")
//                .font(.title)
//                .padding()
//            
//            List {
//                // Get logs for the selected date and group them by date
//                let logsForDate = logManager.getLogsForDate(date)
//                
//                // Check if there are logs for the specified date
//                if logsForDate.isEmpty {
//                    Text("No workouts logged for this date.")
//                        .foregroundColor(.gray)
//                        .padding()
//                } else {
//                    // Group the logs by date (if you have multiple dates in your log)
//                    let groupedLogs = Dictionary(grouping: logsForDate, by: { dateFormatter.string(from: $0.date) })
//                    
//                    // Iterate over the grouped logs and create sections
//                    ForEach(groupedLogs.keys.sorted(), id: \.self) { dateKey in
//                        Section(header: Text(dateKey)) {
//                            ForEach(groupedLogs[dateKey] ?? [], id: \.self) { log in
//                                Text("\(log.exerciseName) - \(log.sets) sets, \(log.reps) reps, \(log.weight) kg")
//                                    .padding()
//                            }
//                        }
//                    }
//                }
//            }
//            .listStyle(InsetGroupedListStyle()) // Optional: style for the list
//        }
//    }
//}//struct ExerciseDetailView: View {
//    @ObservedObject var logManager: WorkoutLogManager
//    var exerciseName: String
//
//    var body: some View {
//        VStack {
//            Text("\(exerciseName) Progress")
//                .font(.title)
//                .padding()
//
//            List {
//                ForEach(logManager.getLogsForExercise(exerciseName)) { log in
//                    Text("Date: \(dateFormatter.string(from: log.date)) - \(log.sets) sets, \(log.reps) reps, \(log.weight) kg")
//                        .padding()
//                }
//            }
//        }
//    }
//}

#Preview {
    DailyWorkoutView()
}
