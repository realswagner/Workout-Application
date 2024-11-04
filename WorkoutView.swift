//
//  WorkoutView.swift
//  WorkoutApp
//
//  Created by cmStudent on 2024/10/10.
//

//import SwiftUI
//
//struct WorkoutView: View {
//    let bodyParts = ["Chest", "Shoulders", "Triceps", "Biceps", "Back", "Legs"]
//    
//    var body: some View {
//        NavigationStack {
//            List(bodyParts, id: \.self) { bodyPart in
//                NavigationLink(destination: WorkoutDetailView(bodyPart: bodyPart)) {
//                    Text(bodyPart)
//                }
//            }
//            .navigationTitle("Body Parts")
//            
//        }
//    }
//}
//
//struct WorkoutDetailView: View {
//    var bodyPart: String
//    var workouts: [String] {
//        switch bodyPart {
//        case "Chest":
//            return ["Bench Press", "Push-Up", "Chest Fly"]
//        case "Shoulders":
//            return ["Shoulder Press", "Lateral Raise", "Front Raise"]
//        case "Triceps":
//            return ["Tricep Dips", "Skull Crushers", "Tricep Pushdown"]
//        case "Biceps":
//            return ["Bicep Curl", "Hammer Curl", "Concentration Curl"]
//        case "Back":
//            return ["Pull-Ups", "Deadlift", "Bent-Over Row"]
//        case "Legs":
//            return ["Squats", "Lunges", "Leg Press"]
//        default:
//            return []
//        }
//    }
//
//    var body: some View {
//        List(workouts, id: \.self) { workout in
//            NavigationLink(destination: WorkoutDetailPage(workout: workout)) {
//                Text(workout)
//            }
//        }
//        .navigationTitle(bodyPart)
//    }
//}
//
//struct WorkoutDetailPage: View {
//    var workout: String
//    
//    var body: some View {
//        VStack {
//            Text(workout)
//                .font(.largeTitle)
//                .padding()
//            
//            // Example placeholder for workout information
//            Text("Detailed explanation of \(workout)")
//                .padding()
//            
//            Spacer()
//        }
//        .navigationTitle(workout)
//        .navigationBarTitleDisplayMode(.inline)
//        
//    }
//}
//
//#Preview {
//    WorkoutView()
//}
import SwiftUI
import Charts

struct WorkoutView: View {
    let bodyParts = ["胸", "肩", "三頭筋", "二頭筋", "背中", "脚"]
//    let bodyPartImages = ["chestDiagram", "shouldersDiagram", "tricepsDiagram", "bicepsDiagram", "backDiagram", "legsDiagram"]
    
    var body: some View {
        NavigationStack {
            List(0..<bodyParts.count, id: \.self) { index in
                NavigationLink(destination: WorkoutDetailView(bodyPart: bodyParts[index])) {
                    HStack(spacing: 15) {
//                        Image(bodyPartImages[index])
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 50, height: 50)
//                            .clipShape(Circle())
//                            .shadow(radius: 4)
                        
                        Text(bodyParts[index])
                            .font(.title2)
                            .foregroundColor(.purple) // Set text color to purple
                            .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    .background(Color(UIColor.systemBackground).opacity(0.9))
                    .cornerRadius(12)
                    .shadow(color: Color.gray.opacity(0.4), radius: 5, x: 2, y: 3)
                }
                .listRowBackground(Color.clear)
            }
            .padding(.vertical, 8)
            .background(Color("Background")) // Use custom background color from assets
            .navigationTitle("筋群")
            .scrollContentBackground(.hidden)
        }
    }
}

struct WorkoutDetailView: View {
    var bodyPart: String
//    var exerciseName: String
    var workouts: [String] {
        switch bodyPart {
        case "胸":
            return ["ベンチプレス", "プッシュアップ", "チェストフライ"]
        case "肩":
            return ["ショルダープレス", "ラテラルレイズ", "フロントレイズ"]
        case "三頭筋":
            return ["トライセプスディップ", "スカルクラッシャー", "トライセプスプッシュダウン"]
        case "二頭筋":
            return ["バイセップカール", "ハンマーカール", "コンセントレーションカール"]
        case "背中":
            return ["プルアップ", "デッドリフト", "ベントオーバーロウ"]
        case "脚":
            return ["スクワット", "ランジ", "レッグプレス"]
        default:
            return []
        }
    }
    
    var body: some View {
        List(workouts, id: \.self) { workout in
            NavigationLink(destination: WorkoutDetailPage(workout: workout)) {
                Text(workout)  // Display the name of the exercise
            }
        }
        .navigationTitle(bodyPart)
    }
}

struct WorkoutDetailPage: View {
    var workout: String
    @State private var workoutLogs: [WorkoutLogEntry] = []
    // Array to store logs for this workout
    
    // Dictionary to hold workout descriptions
    private let workoutDescriptions: [String: String] = [
        "ベンチプレス": "ベンチプレスは、フラットベンチでバーベルを使用して胸に焦点を当てた上半身の筋力トレーニングエクササイズです。",
        "プッシュアップ": "体重を使ったエクササイズで、胸、肩、三頭筋を鍛えます。プランクの姿勢から体を地面に下ろし、再び押し上げます。",
        "チェストフライ": "胸の筋肉をターゲットにしたアイソレーションエクササイズです。ダンベルまたはケーブルマシンを使用し、ベンチに寝た状態で腕を広げたり閉じたりします。",
        
        "ショルダープレス": "ショルダープレスは、三角筋に焦点を当てて肩の筋肉を強化します。肩の高さからダンベルまたはバーベルを上に押し上げる動作を行います。",
        "ラテラルレイズ": "肩の筋肉、特に外側の三角筋のためのアイソレーションエクササイズです。ダンベルを横に上げて、腕が地面と平行になるまで行います。",
        "フロントレイズ": "前方の三角筋をターゲットにします。腕をまっすぐにして、体の前でダンベルを肩の高さまで上げます。",
        
        "トライセプスディップ": "体重を使ったエクササイズで、三頭筋をターゲットにします。ベンチまたはディップバーを使って、体を下ろし上げる動作を行います。",
        "スカルクラッシャー": "三頭筋をターゲットにしたアイソレーションエクササイズです。腕を頭上に伸ばし、バーベルまたはダンベルを額の方に下ろし、その後押し上げます。",
        "トライセプスプッシュダウン": "三頭筋に焦点を当てたエクササイズで、ケーブルマシンを使用し、ハンドルを地面に向かって押し下げ、肘を固定します。",
        
        "バイセップカール": "ウエストから肩の高さまでダンベルまたはバーベルをカールする、バイセップのためのクラシックエクササイズです。バイセップの収縮に焦点を当てます。",
        "ハンマーカール": "手のひらが内側を向いたバイセップカールのバリエーションで、バイセップと前腕の筋肉を鍛えます。",
        "コンセントレーションカール": "内ももに上腕を寄せ、ダンベルを肩の方にカールすることで、バイセップのためのアイソレーションエクササイズです。",
        
        "プルアップ": "背中と二頭筋をターゲットにした体重を使ったエクササイズです。バーにぶら下がり、あごがバーの上に来るまで体を引き上げます。",
        "デッドリフト": "主に下背部、臀部、ハムストリングをターゲットにする複合エクササイズです。背中をまっすぐにした状態でバーベルを地面から腰の高さまで持ち上げます。",
        "ベントオーバーロウ": "特に広背筋と菱形筋をターゲットにする背中の筋肉を鍛えるエクササイズです。腰を曲げ、バーベルまたはダンベルを体の方に引きます。",
        
        "スクワット": "四頭筋、臀部、ハムストリングをターゲットにする複合下半身エクササイズです。膝と腰を曲げて体を下ろし持ち上げます。",
        "ランジ": "四頭筋、臀部、ハムストリングをターゲットにする下半身のエクササイズです。前に足を踏み出し、後ろの膝を地面に向かって曲げます。",
        "レッグプレス": "四頭筋、臀部、ハムストリングをターゲットにするマシンベースの下半身エクササイズです。足で重りを押し出します。"
    ]

        @StateObject private var logManager = WorkoutLogManager.shared
        
        
        var body: some View {
                VStack {
                    title

                    if let description = workoutDescriptions[workout] {
                        Text(description)
                            .padding()
                    } else {
                        Text("説明は利用できません。.")
                            .padding()
                    }
                    if !workoutLogs.isEmpty {
                        Text("進捗の推移")
                            .font(.headline)
                            .padding(.top)
                        Chart(workoutLogs, id: \.id) { log in
                            LineMark(
                                x: .value("日付", log.date),
                                y: .value("体重", log.weight)
                                        )
                                    .symbol(Circle())
                                    .foregroundStyle(.purple)
                                    }
                                .frame(height: 200)
                                .padding()
                                }
                    // Section to display the workout history
                    Text("ワークアウト履歴")
                        .font(.headline)
                        .padding(.top)

                    if workoutLogs.isEmpty {
                        Text("ワークアウト履歴は利用できません。")
                            .foregroundColor(.gray)
                    } else {
                        List {
                            ForEach(logManager.getExerciseHistory(for: workout)) { log in
                                Text("\(log.date, formatter: dateFormatter): \(log.sets) sets, \(log.reps) reps, \(log.weight) kg")
                            }
                        }
                    }

                    Spacer()
                }
                .navigationTitle(workout)
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    // Fetch the logs for the specific workout
                    workoutLogs = getExerciseHistory(for: workout)
                }
            }

            // Extracted title view to clean up the body structure
            private var title: some View {
                Text(workout)
                    .font(.largeTitle)
                    .padding()
            }

            // Function to get the workout history for the specific exercise
            func getExerciseHistory(for exerciseName: String) -> [WorkoutLogEntry] {
                return logManager.getExerciseHistory(for: exerciseName)
            }
        }


// Extracted title view to clean up the body structure
//extension WorkoutDetailPage {
//    private var title: some View {
//        Text(workout)
//            .font(.largeTitle)
//            .padding()
//    }
//}


#Preview {
    WorkoutView()
}
