//
//  ContentView.swift
//  TodayAir
//
//  Created by 김동준 on 2022/12/24.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: Store<WeatherViewState, WeatherViewAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            ZStack {
                viewStore.background.ignoresSafeArea()
                HStack {
                    VStack(alignment: .center) {
                        Group {
                            Text("2022년 8월 15일 \(viewStore.date ?? "")")
                                .font(.system(size: 22))
                                .foregroundColor(viewStore.textColor)
                                .padding()
                            
                            Spacer()
                                .frame(height: 40.0)
                            
                            Text("오후 1시 15분")
                                .foregroundColor(viewStore.textColor)
                                .font(.system(size: 24))
                            
                            Spacer()
                                .frame(height: 20.0)
                            
                            Text("강남구")
                                .font(.system(size: 42))
                                .foregroundColor(viewStore.textColor)
                                .bold()
                        }
                        
                        Spacer()
                            .frame(height: 50.0)
                        
                        Image("smail")
                        
                        Spacer()
                            .frame(height: 50.0)
                        
                        Group {
                            Text("좋음")
                                .foregroundColor(viewStore.textColor)
                                .font(.system(size: 42))
                                .bold()
                            
                            Spacer()
                                .frame(height: 20.0)
                            
                            Text("오늘 공기 최고 좋아요.")
                                .foregroundColor(viewStore.textColor)
                                .font(.title3)
                        }
                        
                        Spacer()
                            .frame(height: 70.0)
                        
                        GeometryReader { proxy in
                            Group {
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(0 ..< 10) { _ in
                                            Spacer()
                                                .frame(width: 15.0)
                                            AirCardView()
                                                .frame(width: 120, height: 180.0)
                                        }
                                        Spacer()
                                            .frame(width: 15.0)
                                    }
                                }
                            }
                            .frame(width: proxy.size.width, height: 180.0)
                        }
                    }
                }
            }
            .onAppear {
                viewStore.send(.viewAppear)
            }
        }
    }
}

enum WeatherViewAction: Equatable {
    case viewAppear
    case networking
}

struct WeatherViewState: Equatable {
    var date: String?
    var background: Color = .blue
    var textColor: Color = .white
    var viewModel: WeatherViewModel?
}

struct WeatherViewModel: Equatable {
    
}

struct WeatherConverter {
    func convert(weather: WeatherDTO) -> WeatherViewModel {
        return WeatherViewModel()
    }
}

struct WeatherEnvironment {
    let weatherService: WeatherService
    let weatherConverter: WeatherConverter
    var effect: (() -> EffectTask<Result<WeatherViewModel, NetworkError>>)?
}

let weatherReducer = Reducer<WeatherViewState, WeatherViewAction, WeatherEnvironment> { state, action, environment in
    switch action {
    case .viewAppear:
//        return environment.effect()
//            .receive(on: RunLoop.main)
//            .catchToEffect()
//            .map { _ in WeatherViewAction.networking }
        return .none
    case .networking:
        return .none
    }
    return .none
}

struct AirCardView: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.white.opacity(0.3).ignoresSafeArea()
                HStack {
                    VStack {
                        Text("미세먼지")
                            .foregroundColor(.white)
                            .font(.body)
                        
                        Spacer()
                            .frame(height: 15.0)
                        
                        Image("smail")
                            .resizable()
                            .frame(width: 50.0, height: 50.0)
                        
                        Spacer()
                            .frame(height: 15.0)
                        
                        Text("좋음")
                            .foregroundColor(.white)
                            .font(.body)
                    }
                }
            }
            .cornerRadius(15.0)
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(initialState: WeatherViewState(), reducer: weatherReducer, environment: WeatherEnvironment(weatherService: WeatherService(), weatherConverter: WeatherConverter())))
        //AirCardView()
    }
}
