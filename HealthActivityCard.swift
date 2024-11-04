//
//  HealthActivityCard.swift
//  WorkoutApp
//
//  Created by cmStudent on 2024/10/26.
//

import SwiftUI

//**********
// File for calorie and step UI view on homepage
//***********

struct Activity {
    let id: Int
    let title: String
    let subtitle: String
    let cardImage: String
    let amount: String
    let type: ActivityType
}
enum ActivityType {
    case steps
    case calories
}

struct HealthActivityCard: View {
    @State var activity: Activity
    var body: some View {
        ZStack {
            Color(uiColor: .systemGray6)
                .cornerRadius(15)
            VStack(spacing: 20){
                HStack(alignment: .top)
                {
                    VStack(alignment: .leading, spacing: 5){
                        if activity.type == .steps {
                            Text("ステップ")
                            } else if activity.type == .calories {
                                Text("消費カロリー")
                            }
                        Text("今日")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: activity.type == .steps ? "figure.walk" : "flame") // Adjust icon based on type
                        .foregroundColor(activity.type == .steps ? .purple : .red)
                }
                
                Text(activity.amount)
                    .font(.system(size: 24))
            }
            .padding()
        }
    }
}

struct HealthActivityCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview for steps activity
            HealthActivityCard(activity: Activity(id: 0, title: "Daily Steps", subtitle: "Goal", cardImage: "figure.walk", amount: "6,500", type: .steps))

            // Preview for calories activity
            HealthActivityCard(activity: Activity(id: 1, title: "Calories Burned", subtitle: "Goal", cardImage: "flame", amount: "350", type: .calories))
        }
    }
}
