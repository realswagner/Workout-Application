//
//  ContentView.swift
//  WorkoutApp
//
//  Created by cmStudent on 2024/10/01.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    @AppStorage("stepGoal") private var stepGoal: Int = 10000
    @State private var isSecondWelcomeScreen: Bool = false
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var gender: Gender = .male
    @State private var selectedOption: Int = 0
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @AppStorage("calculatedCalories") private var calories: Int = 0
    @StateObject private var logManager = WorkoutLogManager.shared
//    @State private var calories: Int = 0
    
    let options = ["運動なし(週０回)", "ちょっとした運動(週１−３回)","よく運動する(週３−５回）", "激しい運動(週６−７回）"]
    let optionsValues = [1.16, 1.31, 1.54, 1.69]
    
    var body: some View {
        if isFirstLaunch{
            if isSecondWelcomeScreen{
                SecondWelcomeScreen(isFirstLaunch: $isFirstLaunch, calories: $calories, isSecondWelcomeScreen: $isSecondWelcomeScreen)
            } else {
                WelcomeScreen (isFirstLaunch:               $isFirstLaunch,
                    isSecondWelcomeScreen:
                    $isSecondWelcomeScreen,
                    name: $name,
                    age: $age,
                    height: $height,
                    weight: $weight,
                    gender: $gender,
                    selectedOption: $selectedOption,
                    showAlert: $showAlert,
                               alertMessage: $alertMessage, calories: $calories,
                    options: options,
                    optionsValues: optionsValues
                              )
            } } else {
                
                MainTabView(isFirstLaunch: $isFirstLaunch, calories: $calories)
                    .environmentObject(HealthManager())
                //            .fullScreenCover(isPresented: .constant(true
                //                                                   ), content: {
                //                    WelcomeScreen(name: $name, age: $age, height: $height, weight: $weight, selectedOption: $selectedOption, isFirstLaunch: $isFirstLaunch, options: options, optionsValues: optionsValues)
                //                })
                //        }
            }
        }
    }
enum Gender: String, CaseIterable {
    case male = "男"
    case female = "女"
}

struct WelcomeScreen: View {
    @Binding var isFirstLaunch: Bool
    @Binding var isSecondWelcomeScreen: Bool
    @Binding var name: String
    @Binding var age: String
    @Binding var height: String
    @Binding var weight: String
    @Binding var gender: Gender
    @Binding var selectedOption: Int
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    @Binding var calories: Int
    let options: [String]
    let optionsValues: [Double]
    
    var body: some View {
        VStack {
            Text("ようこそ!")
                .font(.system(size:60))
                .bold()
                .foregroundColor(.purple)
                .padding()
            Text("正確な1日の消費カロリー")
                .font(.largeTitle)
                .padding()
                .bold()
            TextField("年齢を入力:",text: $age)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                hideKeyboard()
                            }
                        }
                    }
            TextField("体重を入力(キロ):", text: $weight)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                hideKeyboard()
                            }
                        }
                    }
            TextField("身長を入力(センチ):", text: $height)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                hideKeyboard()
                            }
                        }
                    }
            Picker("性別", selection: $gender){
                ForEach(Gender.allCases, id: \.self){
                    gender in Text(gender.rawValue).tag(gender)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            Text("活動レベルを選択してください：")
                .bold()
            Picker("活動レベルを選択:", selection: $selectedOption){
                ForEach(0..<options.count, id: \.self){
                    index in Text(options[index]).tag(index)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            Button("始めます!"){
                validateInputs()
            }
            .padding()
            .bold()
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(10)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("無効な入力"), message: Text(alertMessage),dismissButton: .default(Text("戻る")))
            }
            
        }
        .padding()
    }
    private func validateInputs(){ // Checks to see if all info is entered correctly
        guard let ageValue = Int(age), let weightValue = Int(weight), let heightValue = Int(height) else {
            alertMessage = "すべての項目を入力してください"
            showAlert = true
            return
        }
        if ageValue <= 0 || ageValue > 120 {
            alertMessage = "1～120歳の間で有効な年齢を入力してください。"
            showAlert = true
            return
        } else if weightValue <= 0 || weightValue > 500 {
            alertMessage = "1～500キロの間で有効な重量を入力してください。"
            showAlert = true
            return
        } else if heightValue <= 0 || heightValue >= 250{
            alertMessage = "1～250cmの間で有効な身長を入力してください。"
            showAlert = true
            return
        } else {
            let activityLevel = optionsValues[selectedOption]
            calories = calculateCalories(age: ageValue, weight: weightValue, height: heightValue, gender: gender, activityLevel: activityLevel)
                    
            UserDefaults.standard.set(ageValue, forKey: "userAge")
            UserDefaults.standard.set(weightValue, forKey: "userWeight")
            UserDefaults.standard.set(heightValue, forKey: "userHeight")
            UserDefaults.standard.set(optionsValues[selectedOption], forKey: "userActivityLevel")
            UserDefaults.standard.set(gender.rawValue, forKey: "userGender")
            UserDefaults.standard.set(calories, forKey: "calculatedCalories")
            isSecondWelcomeScreen = true
        }
    }
    
}
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

import SwiftUI

struct SecondWelcomeScreen: View {
    @Binding var isFirstLaunch: Bool
    @Binding var calories: Int
    @Binding var isSecondWelcomeScreen: Bool
    @State private var selectedGoal: Double = 1.0
    @AppStorage("stepGoal") private var stepGoal: Int = 10000
    private let goalOptions = [
        "たくさん体重を減らしたい",
        "普通のペースで体重を減らしたい",
        "体重に満足している",
        "少し体重を増やしたい",
        "たくさん体重を増やしたい"
    ]
    private let goalValues = [0.8, 0.88, 1.0, 1.12, 1.2] // Multipliers for each weight loss option

    var body: some View {
        VStack(spacing: 20) { // Increased spacing for better organization
            Text("これは前回入力した情報に基づく基礎代謝量です。今後の目安にしてください。活動レベルや測定値が変更された場合は、後で設定で変更することができます。")
                .font(.system(size: 24)) // Adjusted font size for readability
                .foregroundColor(.purple)
                .multilineTextAlignment(.center)
                .padding(.horizontal) // Horizontal padding for better layout

            Text("1日の推定使用カロリー:")
                .font(.system(size: 24)) // Adjusted font size
                .padding()

            Text("\(calories)")
                .font(.system(size: 80)) // Large calorie display
                .foregroundColor(.purple)

            Text("カロリー計算の詳細については、設定の情報のセクションをご覧ください。")
                .font(.footnote) // Changed to footnote for smaller text
                .foregroundColor(.gray)
                .multilineTextAlignment(.center) // Centered text alignment
                .padding(.horizontal)

            Picker("目標", selection: $selectedGoal) {
                ForEach(goalOptions.indices, id: \.self) { index in
                    Text(goalOptions[index]).tag(goalValues[index])
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: selectedGoal) { newValue in
                UserDefaults.standard.set(newValue, forKey: "goalMultiplier")
            }
            .padding(.horizontal) // Added horizontal padding for consistency

            Text("毎日のステップ目標を設定する")
                .font(.title2)
                .padding()

            Stepper(value: $stepGoal, in: 1000...50000, step: 1000) {
                Text("ステップ目標: \(stepGoal)")
                    .font(.title3)
                    .foregroundColor(.purple)
            }
            .padding(.horizontal) // Added padding to Stepper

            Spacer()

            Text("後で測定値が変わった場合は、設定で更新できます。")
                .padding()
                .multilineTextAlignment(.center) // Centered text alignment

            Button(action: {
                isSecondWelcomeScreen = false
                isFirstLaunch = false
                let adjustedCalories = Int(Double(calories) * selectedGoal)
                UserDefaults.standard.set(adjustedCalories, forKey: "calculatedCalories")
            }) {
                Text("次へ")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity) // Full width button
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal) // Added horizontal padding to button
        }
        .padding() // Overall padding for the VStack
        .background(Color(UIColor.systemBackground)) // Optional: Set a background color to match app theme
        .cornerRadius(10) // Rounded corners for the entire view
        .shadow(radius: 5) // Optional: Add shadow for depth
    }
}
struct MainTabView: View{
    @Binding var isFirstLaunch: Bool
    @Binding var calories: Int
//    @EnvironmentObject var manager: HealthManager
    @StateObject private var logManager = WorkoutLogManager.shared
    var body: some View{
        TabView{
            HomePage(manager: HealthManager())
                .tabItem { Label("ホーム", systemImage: "house.fill" )}
            WorkoutView()
                .tabItem{
                    Label("運動", systemImage: "dumbbell.fill")
                }
            DailyWorkoutView()
                .tabItem{
                    Label("ローグ", systemImage: "calendar.circle.fill")
                }
            SettingsView(isFirstLaunch: $isFirstLaunch)
                .tabItem{
                    Label("設定", systemImage: "gearshape")
                }

//                .environmentObject(manager)
        }
    }
}



//func calculateCalories(age: Int, weight: Int, height: Int, gender: Gender, activityLevel: Double) -> Int
//{
//    let bmr: Double
//    if gender == .male
//    {
//        bmr = 88.362 + (13.397 * Double(weight)) + (4.799 * Double(height)) - (5.677 * Double(age))
//    } else
//    {
//        bmr = 447.593 + (9.247 * Double(weight)) + (3.098 * Double(height)) - (4.330 * Double(age))
//    }
//    
//    let tdee = bmr * activityLevel
//    return Int(tdee.rounded())
//}

#Preview {
    ContentView()
}
