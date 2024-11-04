//
//  UtilityFunctions.swift
//  WorkoutApp
//
//  Created by cmStudent on 2024/10/10.
//



//function to calculate TDEE and calories
import Foundation

func calculateCalories(age: Int, weight: Int, height: Int, gender: Gender, activityLevel: Double) -> Int
{
    let bmr: Double
    if gender == .male
    {
        bmr = 88.362 + (13.397 * Double(weight)) + (4.799 * Double(height)) - (5.677 * Double(age))
    } else
    {
        bmr = 447.593 + (9.247 * Double(weight)) + (3.098 * Double(height)) - (4.330 * Double(age))
    }
    
    let tdee = bmr * activityLevel
    return Int(tdee.rounded())
}
