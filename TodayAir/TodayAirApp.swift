//
//  TodayAirApp.swift
//  TodayAir
//
//  Created by 김동준 on 2022/12/24.
//

import SwiftUI
import ComposableArchitecture

@main
struct TodayAirApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: Store(initialState: WeatherViewState(), reducer: weatherReducer, environment: WeatherEnvironment(weatherService: WeatherService(), weatherConverter: WeatherConverter())))
        }
    }
}
