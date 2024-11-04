//
//  SettingsView.swift
//  WorkoutApp
//
//  Created by cmStudent on 2024/10/10.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isFirstLaunch: Bool
    @State private var showConfirmationAlert = false
    @State private var isResetConfirmed = false
    @State private var isSettingsSheetPresented = false
    @State private var showingAboutView = false
    @AppStorage("userAge") private var age: Int = 0
    @AppStorage("userGender") private var genderRawValue: String = Gender.male.rawValue // Use String for gender
    private var gender: Gender {
        Gender(rawValue: genderRawValue) ?? .male
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("設定") // Large title
                .font(.largeTitle)
                .bold()
                .padding(.top)

            Button(action: {
                showingAboutView.toggle()
            }) {
                Text("情報")
                    .frame(maxWidth: .infinity) // Makes button full width
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $showingAboutView) {
                AboutView()
            }

            Button("プロフィール設定の編集") {
                isSettingsSheetPresented = true
            }
            .frame(maxWidth: .infinity) // Makes button full width
            .padding()
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(10)
            .sheet(isPresented: $isSettingsSheetPresented) {
                SettingsSheet(isPresented: $isSettingsSheetPresented)
            }

            Button("すべてのデータをリセットする") {
                showConfirmationAlert = true
            }
            .frame(maxWidth: .infinity) // Makes button full width
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
            .alert(isPresented: $showConfirmationAlert) {
                Alert(
                    title: Text("確認"),
                    message: Text("リセットを押すと、すべてのログとデータがリセットされます。"),
                    primaryButton: .destructive(Text("リセット")) {
                        isFirstLaunch = true // Reset flag to show the first welcome screen again
                        WorkoutLogManager.shared.clearAllLogs() // Clear all logs
                        UserDefaults.standard.removeObject(forKey: "weight")
                        UserDefaults.standard.removeObject(forKey: "height")
                        UserDefaults.standard.removeObject(forKey: "age")
                        // Reset any additional user data here
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .padding() // Add padding around the entire view
    }
}

struct SettingsSheet: View {
    @Binding var isPresented: Bool
    @State private var weight: Double = UserDefaults.standard.double(forKey: "userWeight")
    @State private var height: Double = UserDefaults.standard.double(forKey: "userHeight")
    @State private var selectedActivityLevel: Double = UserDefaults.standard.double(forKey: "activityLevel")
    @State private var selectedGoal: Double = UserDefaults.standard.double(forKey: "goalMultiplier")
    @AppStorage("stepGoal") private var stepGoal: Int = 10000 // Default to 10,000 steps

    private let activityOptions = ["運動なし(週０回)", "ちょっとした運動(週１−３回)", "よく運動する(週３−５回）", "激しい運動(週６−７回）"]
    private let activityValues = [1.16, 1.31, 1.54, 1.69]
    private let goalOptions = ["たくさん体重を減らしたい", "普通のペースで体重を減らしたい", "体重に満足している", "少し体重を増やしたい", "たくさん体重を増やしたい"]
    private let goalValues = [0.8, 0.88, 1.0, 1.12, 1.2]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("身体情報")) {
                    // Weight Input
                    HStack {
                        Text("体重 (キロ)")
                        TextField("Enter weight", value: $weight, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                    }
                    
                    // Height Input
                    HStack {
                        Text("身長 (cm)")
                        TextField("Enter height", value: $height, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                    }
                    
                    // Activity Level Picker
                    Picker("活動レベル", selection: $selectedActivityLevel) {
                        ForEach(activityOptions.indices, id: \.self) { index in
                            Text(activityOptions[index]).tag(activityValues[index])
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    // Goal Picker
                    Picker("目標", selection: $selectedGoal) {
                        ForEach(goalOptions.indices, id: \.self) { index in
                            Text(goalOptions[index]).tag(goalValues[index])
                        }
                    }
                    
                    // Step Goal Stepper
                    Stepper(value: $stepGoal, in: 1000...50000, step: 1000) {
                        Text("毎日のステップ目標: \(stepGoal)")
                            .foregroundColor(.purple)
                            .font(.body)
                    }
                }
                
                // Save Button
                Button(action: {
                    if(weight == 0) {return}
                    if(height == 0) {return}
                    saveUserData()
                    isPresented = false
                }) {
                    Text("保存")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.vertical)
                .listRowBackground(Color.clear) // Ensures button background is separate from form rows
            }
            .navigationTitle("設定")
        }
    }
    
    private func saveUserData() {
        UserDefaults.standard.set(weight, forKey: "userWeight")
        UserDefaults.standard.set(height, forKey: "userHeight")
        UserDefaults.standard.set(selectedActivityLevel, forKey: "activityLevel")
        UserDefaults.standard.set(selectedGoal, forKey: "goalMultiplier") // Save goal multiplier
        // Recalculate and save adjusted calories
        let baseCalories = calculateCalories(age: UserDefaults.standard.integer(forKey: "userAge"), weight: Int(weight), height: Int(height), gender: Gender(rawValue: UserDefaults.standard.string(forKey: "userGender") ?? "male") ?? .male, activityLevel: selectedActivityLevel)
        let adjustedCalories = Int(Double(baseCalories) * selectedGoal)
        UserDefaults.standard.set(adjustedCalories, forKey: "calculatedCalories")
    }
}

struct AboutView: View {
    var body: some View {
        NavigationView {
            ScrollView { // Use ScrollView for scrolling capability
                VStack(alignment: .leading, spacing: 20) {
                    Text("カロリー計算について")
                        .font(.headline)
                        .bold()

                    Text("このアプリでは、ハリス・ベネディクト方程式（改訂版）を使用しています。")
                        .font(.body)
                    Text("・男性の場合: TDEE（総日常エネルギー消費量） = 88.362 + (13.397 × 体重（kg）) + (4.799 × 身長（cm）) − (5.677 × 年齢（年）)")
                        .font(.body)
                    Text("・女性の場合: TDEE = 447.593 + (9.247 × 体重（kg）) + (3.098 × 身長（cm）) − (4.330 × 年齢（年）)これは、あなたの総日常エネルギー消費量、つまり、あなたの日常の維持カロリー摂取量を計算するものです。これは、選択した一般的な活動レベルによって修正されます。")
                        .font(.body)

                    Text("この情報は正確なものではなく、良く研究された科学的な公式による一般的でおおよその評価であることを理解してください。体重減少や体重増加の修正も、あらかじめ定義された一般的なガイドラインを使用します。たとえば、「通常のペースで体重を減らしたい」を選択した場合、これにより日常の維持カロリーに約88％の係数が掛けられ、したがって、以前の計算に基づいて消費するカロリーよりも少ないカロリーを1日に摂取することになります。")
                        .font(.body)

                    Text("繰り返しになりますが、これらの値は人によって異なる場合があり、日常のカロリー推定の正確性は、既存の医学的状態や異常な体組成、代謝条件などの外的要因によって影響を受ける可能性があります。これらの値は一般的に健康な個人を考慮して計算されているため、これらのガイドラインに従う際には注意を払い、自分自身にどれだけうまく機能するか、または資格を持つ医療専門家の指導の下で調整してください")
                        .font(.body)

                    Text("ウェイトリフティングについて")
                        .font(.headline)

                    Text("続行する前に、フィットネス環境でのすべての安全手順を遵守し、自分の体、ニーズ、医療専門家からのアドバイスに基づいて安全かつ健康的な実践を行うことが非常に重要です。既存の病状がある場合や、フィットネスの旅を安全に進める方法が不明な場合は、まずかかりつけの医師に相談し、その後、資格を持つトレーナーに相談してください。")
                        .font(.body)

                    Text("科学的な合意は、筋肉の増加と力の向上の主な要因として「漸進的オーバーロード」を挙げています。「漸進的オーバーロード」とは、時間が経つにつれて、一般的に重量を徐々に増加させることを意味します。これは筋肉の成長、力の成長、健康な筋肉の機能のために推奨される方法であり、この構造を遵守するために組み込まれたログと進捗追跡システムを使用することをお勧めします。もちろん、このアプリをお好きなように使用できますが、主な目的が力、筋肉、活力の向上である場合は、漸進的オーバーロードをお勧めします。")
                        .font(.body)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("情報")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    @State static var isFirstLaunch = true // Create a State variable for preview

    static var previews: some View {
        SettingsView(isFirstLaunch: $isFirstLaunch) // Pass the State variable as binding
    }
}

