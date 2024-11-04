//
//  SplashScreenView.swift
//  WorkoutApp
//
//  Created by cmStudent on 2024/10/24.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    @EnvironmentObject var manager: HealthManager
    
    var body: some View {
        if isActive {
            ContentView()
                .environmentObject(manager)
        }
        else{
            VStack {
                VStack {
                    Image(systemName: "dumbbell")
                        .font(.system(size: 90))
                        .foregroundColor(.purple)
                    Text("Workout +")
                        .font(Font.custom("Baskerville-Bold", size: 30))
                
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear{
                    withAnimation(.easeIn(duration: 1.2)){
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                    withAnimation{
                        self.isActive = true
                    }
                }
            }
        }
       
    }
}

struct SplashScreenView_Previews: PreviewProvider{
    static var previews: some View {
        SplashScreenView()
    }
}
