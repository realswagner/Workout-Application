//
//  ExerciseLog.swift
//  WorkoutApp
//
//  Created by cmStudent on 2024/10/17.
//

import Foundation
struct WorkoutLogEntry: Identifiable, Hashable, Codable {
    let id: UUID // Ensure each entry has a unique identifier
    let date: Date
    let exerciseName: String
    let sets: Int
    let reps: Int
    let weight: Double
    let sessionID: UUID // Unique identifier for each session

        init(
            id: UUID = UUID(),
            date: Date,
            exerciseName: String,
            sets: Int,
            reps: Int,
            weight: Double,
            sessionID: UUID = UUID() // Generate a new session ID by default
        ) {
            self.id = id
            self.date = date
            self.exerciseName = exerciseName
            self.sets = sets
            self.reps = reps
            self.weight = weight
            self.sessionID = sessionID
        }

    // This will allow two WorkoutLogEntry instances to be considered equal if all properties are the same
    static func == (lhs: WorkoutLogEntry, rhs: WorkoutLogEntry) -> Bool {
        return lhs.id == rhs.id &&
               lhs.date == rhs.date &&
               lhs.exerciseName == rhs.exerciseName &&
               lhs.sets == rhs.sets &&
               lhs.reps == rhs.reps &&
               lhs.weight == rhs.weight
    }

    // This is used to create a hash value for the instance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(date)
        hasher.combine(exerciseName)
        hasher.combine(sets)
        hasher.combine(reps)
        hasher.combine(weight)
    }
}
class WorkoutLogManager: ObservableObject {
    static let shared = WorkoutLogManager() // Singleton instance
    @Published var logs: [WorkoutLogEntry] = [] {
        didSet {
            saveLogs() // Save logs whenever they are modified
        }
    }

    private let workoutLogsKey = "WorkoutLogsKey" // Key for UserDefaults storage

    private init() {
        loadLogs() // Load logs when the manager is initialized
    }

    // Function to add a new log entry
    func addLog(entry: WorkoutLogEntry) {
        logs.append(entry)
    }

    // Function to get exercise history based on the exercise name
    func getExerciseHistory(for exerciseName: String) -> [WorkoutLogEntry] {
        return logs.filter { $0.exerciseName == exerciseName }
    }

    // Function to get logs for a specific date
    func getLogsForDate(_ date: Date) -> [WorkoutLogEntry] {
        let calendar = Calendar.current
        return logs.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    // MARK: - Persistence

    private func saveLogs() {
        // Convert logs to data using JSONEncoder
        if let encodedLogs = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(encodedLogs, forKey: workoutLogsKey)
        }
    }

    private func loadLogs() {
        // Retrieve data from UserDefaults and decode it
        if let savedLogsData = UserDefaults.standard.data(forKey: workoutLogsKey),
           let decodedLogs = try? JSONDecoder().decode([WorkoutLogEntry].self, from: savedLogsData) {
            logs = decodedLogs
        }
    }
    func clearAllLogs() {
        logs.removeAll()
    }
}

