//
//  HomeView.swift
//  WorkoutApp
//
//  Created by cmStudent on 2024/10/10.
//

import SwiftUI

struct HomePage: View {
    @State private var showingWorkoutSheet = false
    @AppStorage("calculatedCalories") private var calories: Int = 0
    @ObservedObject var manager: HealthManager
    @AppStorage("stepGoal") private var stepGoal: Int = 10000
    
    var body: some View {
        NavigationView {
            VStack {
                Text("1日の目標カロリー:")
                    .font(.system(size: 35))
                Text("\(calories)")
                    .font(.system(size: 50))
                    .foregroundColor(.purple)
                    .bold()
                LazyVGrid(columns: Array(repeating: GridItem(spacing:20), count:2)){
                    ForEach(manager.activities.sorted(by: { $0.value.id < $1.value.id}), id: \.key){ item in
                        HealthActivityCard(activity: item.value)
                        
                    }
                }
                .padding(.horizontal)
                ProgressRingView(stepCount: manager.stepCount, stepGoal: stepGoal)
                    .padding(.vertical)
                Button("今日のトレーニング記録!") {
                    showingWorkoutSheet.toggle()
                }
                .buttonStyle(PurpleButtonStyle())
                .sheet(isPresented: $showingWorkoutSheet) {
                    WorkoutLoggingSheet()
                }
                
                Spacer()
            }
            .navigationTitle("ホーム")
            .onAppear {
                manager.requestAuthorization()
            }
        }
    }
}

struct WorkoutLoggingSheet: View {
    @State private var workouts: [WorkoutLogEntry] = [] // Array to store added workouts
    @State private var selectedDate: Date = Date()
    @State private var showingDatePicker: Bool = false
    @State private var showingMuscleGroupSheet: Bool = false
    
    var body: some View {
        VStack {
            // Display the current date
            Text("日付け: \(dateFormatter.string(from: selectedDate))")
                .padding()
                .foregroundColor(.purple)
                .font(.title)
                .bold()
            
            // Button to change the date
            Button("日付変更") {
                showingDatePicker.toggle()
            }
            .buttonStyle(PurpleButtonStyle()) // Apply custom button style

            if showingDatePicker {
                VStack {
                    DatePicker("日付を選択", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                        .background(Color(UIColor.systemBackground)) // Sets background to adapt to light/dark mode
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .colorScheme(.light) // Forces the DatePicker to use light mode colors
                        .accentColor(.purple)

                    Button("終わり") {
                        showingDatePicker = false
                    }
                    .buttonStyle(PurpleButtonStyle()) // Apply custom button style
                }
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 10)
                .padding()
            }

            Text("追加するトレーニング")
                .font(.headline)
                .padding(.top)

            // List of workout entries displayed as styled tiles
            ForEach(workouts) { log in
                VStack(alignment: .leading, spacing: 4) {
                    Text(log.exerciseName)
                        .font(.headline)
                        .padding(.bottom, 2)
                    
                    HStack {
                        Text("\(log.sets) セート")
                        Spacer()
                        Text("\(log.reps) レープ")
                    }
                    .font(.subheadline)
                    
                    Text("\(log.weight, specifier: "%.1f") キロ")
                        .font(.subheadline)
                        .padding(.top, 2)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.purple, lineWidth: 1)
                )
                .padding(.horizontal)
            }

            // Button to add an exercise
            Button(action: {
                showingMuscleGroupSheet.toggle()
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("もっと追加する")
                }
            }
            .buttonStyle(PurpleButtonStyle()) // Apply custom button style
            .sheet(isPresented: $showingMuscleGroupSheet) {
                MuscleGroupSelectionSheet { newWorkout in
                    workouts.append(newWorkout)
                }
            }

            // Submit button for logging the entire workout
            Button("ワークアウトを提出") {
                for workout in workouts {
                    let newWorkout = WorkoutLogEntry(
                        id: UUID(),
                        date: selectedDate, exerciseName: workout.exerciseName,
                        sets: workout.sets,
                        reps: workout.reps,
                        weight: workout.weight // Assign selected date here
                    )
                    WorkoutLogManager.shared.addLog(entry: newWorkout)
                }
                workouts.removeAll() // Clear local workouts after logging
            }
            .buttonStyle(PurpleButtonStyle()) // Apply custom button style
            .padding()
        }
        .padding()
    }
}

struct MuscleGroupSelectionSheet: View {
    @Environment(\.presentationMode) var presentationMode
    let muscleGroups = ["胸", "背中", "肩", "脚", "腕"]
    var onExerciseLogged: (WorkoutLogEntry) -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("筋肉群を選択")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(muscleGroups, id: \.self) { group in
                            NavigationLink(destination: ExerciseSelectionSheet(muscleGroup: group, onExerciseLogged: onExerciseLogged)) {
                                Text(group)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.purple.opacity(0.15))
                                    .foregroundColor(.purple)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("閉じる")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding([.horizontal, .bottom], 20)
            }
            .frame(maxHeight: UIScreen.main.bounds.height * 0.7)
            .background(Color(UIColor.systemGroupedBackground))
            .cornerRadius(15)
            .shadow(radius: 5)
        }
    }
}

struct ExerciseSelectionSheet: View {
    var muscleGroup: String
    var onExerciseLogged: (WorkoutLogEntry) -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("\(muscleGroup)のエクササイズ")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 20)

            let exercises = getExercisesFor(muscleGroup)

            ScrollView {
                VStack(spacing: 15) {
                    ForEach(exercises, id: \.self) { exercise in
                        NavigationLink(destination: SetRepsWeightEntryView(exerciseName: exercise) { log in
                            onExerciseLogged(log)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text(exercise)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple.opacity(0.15))
                                .foregroundColor(.purple)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 20)

            Spacer()
        }
        .navigationTitle(muscleGroup)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground))
    }

    func getExercisesFor(_ muscleGroup: String) -> [String] {
        switch muscleGroup {
        case "胸":
            return ["ベンチプレス", "インクラインダンベルプレス", "チェストフライ"]
        case "背中":
            return ["デッドリフト", "プルアップ", "ベントオーバーロー"]
        case "肩":
            return ["ショルダープレス", "ラテラルレイズ", "フロントレイズ"]
        case "脚":
            return ["スクワット", "ランジ", "レッグプレス"]
        case "腕":
            return ["バイセップカール", "トライセップディップ", "ハンマーカール"]
        default:
            return []
        }
    }
}

struct ExerciseLogInputView: View {
    var exerciseName: String
    @State private var sets: Int = 0
    @State private var reps: Int = 0
    @State private var weight: Double = 0.0
    @Environment(\.presentationMode) var presentationMode // To dismiss the view
    @Binding var workouts: [WorkoutLogEntry] // Pass in the workout array to store the log

    var body: some View {
        VStack {
            Text("\(exerciseName)をログする")
                .font(.largeTitle)
                .padding()

            Stepper("セット: \(sets)", value: $sets, in: 1...20)
                .padding()

            Stepper("レップ: \(reps)", value: $reps, in: 1...50)
                .padding()

            VStack(alignment: .leading) {
                Text("重量 (kg):")
                TextField("重量を入力", value: $weight, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }

            Button("エクササイズをログする") {
                // Log the data
                let logEntry = WorkoutLogEntry(id: UUID(), date: Date(), exerciseName: exerciseName, sets: sets, reps: reps, weight: weight)
                workouts.append(logEntry) // Save the log
                presentationMode.wrappedValue.dismiss() // Close the sheet
            }
            .buttonStyle(.bordered)
            .padding()

            Spacer()
        }
        .padding()
    }
}

struct SetRepsWeightEntryView: View {
    var exerciseName: String
    var onSubmit: (WorkoutLogEntry) -> Void // Callback to pass the log data
    @State private var sets: Int = 1
    @State private var reps: Int = 1
    @State private var weight: Double = 0.0
    @Environment(\.presentationMode) var presentationMode // To dismiss the view

    var body: some View {
        VStack(spacing: 20) {
            Text("\(exerciseName)をログする")
                .font(.title2)
                .foregroundColor(.purple)
                .padding(.top)

            Stepper("セット: \(sets)", value: $sets, in: 1...20)
                .font(.body)
                .padding(.horizontal)

            Stepper("レップ: \(reps)", value: $reps, in: 1...50)
                .font(.body)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 5) {
                Text("重量 (キロ):")
                    .font(.subheadline)

                TextField("重量を入力", value: $weight, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            }
            .padding(.bottom, 20)

            Button(action: {
                let workoutLogEntry = WorkoutLogEntry(
                    id: UUID(),
                    date: Date(),
                    exerciseName: exerciseName,
                    sets: sets,
                    reps: reps,
                    weight: weight
                )
                onSubmit(workoutLogEntry)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("エクササイズをログする")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: 4)
        .padding()
    }
}



let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage(manager: HealthManager())
    }
}
struct PurpleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: configuration.isPressed ? 0 : 5)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

struct ProgressRingView: View {
    var stepCount: Double
    var stepGoal: Int
    var ringColor: Color = .purple

    var progress: Double {
        min(stepCount / Double(stepGoal), 1.0) // Limit to 100%
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(ringColor)

            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(ringColor)
                .rotationEffect(Angle(degrees: -90))

            VStack {
                Text("\(Int(stepCount))")
                    .font(.title)
                    .bold()
                Text("\(stepGoal) ステップ")
                    .font(.subheadline)
            }
        }
        .frame(width: 200, height: 200) // Adjust size as needed
    }
}
