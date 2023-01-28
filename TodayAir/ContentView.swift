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
                            Text("2023년 1월 28일 \(viewStore.date ?? "")")
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
                            
                            Text("서울")
                                .font(.system(size: 42))
                                .foregroundColor(viewStore.textColor)
                                .bold()
                        }
                        
                        Spacer()
                            .frame(height: 50.0)
                        
                        Image(viewStore.airs.first?.grade.iconName ?? "")
                        
                        Spacer()
                            .frame(height: 50.0)
                        
                        Group {
                            Text(viewStore.airs.first?.grade.airState ?? "")
                                .foregroundColor(viewStore.textColor)
                                .font(.system(size: 42))
                                .bold()
                            
                            Spacer()
                                .frame(height: 20.0)
                            
                            Text(viewStore.airs.first?.grade.iconMessage ?? "")
                                .foregroundColor(viewStore.textColor)
                                .font(.title3)
                        }
                        
                        Spacer()
                            .frame(height: 70.0)
                        
                        GeometryReader { proxy in
                            Group {
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(viewStore.airs ?? [], id: \.self) { air in
                                            Spacer()
                                                .frame(width: 15.0)
                                            AirCardView(air: air)
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
    
    case updateViewModel(Result<WeatherDTO, NetworkError>)
}

struct WeatherViewState: Equatable {
    var date: String?
    var background: Color = .blue
    var textColor: Color = .white
    var airs: [Air] = []
}

struct WeatherConverter {
    func convert(weather: WeatherDTO) -> [Air] {
        let pm10Grade = AirGrade.init(rawValue: weather.pm10Grade ?? "") ?? .unknown
        let pm10 = Air(name: "미세먼지", grade: pm10Grade, value: weather.pm10Value)
        let coGrade = AirGrade.init(rawValue: weather.coGrade ?? "") ?? .unknown
        let co = Air(name: "탄소", grade: coGrade, value: weather.coValue)
        let pm25Grade = AirGrade.init(rawValue: weather.pm25Grade ?? "") ?? .unknown
        let pm25 = Air(name: "초미세먼지", grade: pm25Grade, value: weather.pm25Value)
        let o3Grade = AirGrade.init(rawValue: weather.o3Grade ?? "") ?? .unknown
        let o3 = Air(name: "오존", grade: o3Grade, value: weather.o3Value)
        let no2Grade = AirGrade.init(rawValue: weather.no2Grade ?? "") ?? .unknown
        let no2 = Air(name: "이산화질소", grade: no2Grade, value: weather.no2Value)
        return [pm10, co, pm25, o3, no2]
    }
}

struct Air: Hashable {
    static func == (lhs: Air, rhs: Air) -> Bool {
        lhs.value == rhs.value && lhs.name == rhs.name
    }
    var name: String
    var grade: AirGrade
    var value: String?
}


enum AirGrade: String {
    case good = "1"
    case bad = "2"
    case normal = "3"
    case worst = "4"
    case unknown = "5"

    var airState: String {
        switch self {
        case .good:
            return "좋음"
        case .bad:
            return "나쁨"
        case .normal:
            return "보통"
        case .worst:
            return "매우나쁨"
        case .unknown:
            return "정보없음"
        default:
            return "정보없음"
        }
    }
    
    var iconName: String {
        switch self {
        case .good:
            return "smail"
        case .bad:
            return "bad"
        case .normal:
            return "normal"
        case .worst:
            return "worst"
        case .unknown:
            return "unknown"
        default:
            return "정보없음"
        }
    }
    
    var iconMessage: String {
        switch self {
        case .good:
            return "오늘 공기 최고 좋아요."
        case .bad:
            return "오늘 공기 나빠요."
        case .normal:
            return "오늘 공기 보통이에요."
        case .worst:
            return "오늘 공기 최악이에요."
        case .unknown:
            return "서버에서 데이터를 가져오지 못했습니다."
        }
    }
}

struct WeatherEnvironment {
    let weatherService: WeatherService
    let weatherConverter: WeatherConverter
    var effect: (() -> EffectTask<Result<[Air], NetworkError>>)?
}

let weatherReducer = Reducer<WeatherViewState, WeatherViewAction, WeatherEnvironment> { state, action, environment in
    switch action {
    case .viewAppear:
        return .task { [state] in
            return .updateViewModel(await environment.weatherService.request(api: .fetchWeather))
        }
    case .networking:
        return .none
    case .updateViewModel(let result):
        switch result {
        case .success(let weatherDTO):
            print("weather \(weatherDTO)")
            state.airs = environment.weatherConverter.convert(weather: weatherDTO)
        case .failure(let error):
            print("error! \(error)")
        }
    }
    return .none
}

struct AirCardView: View {
    let air: Air
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.white.opacity(0.3).ignoresSafeArea()
                HStack {
                    VStack {
                        Text("\(air.name)")
                            .foregroundColor(.white)
                            .font(.body)
                        
                        Spacer()
                            .frame(height: 15.0)
                        
                        Image(air.grade.iconName)
                            .resizable()
                            .frame(width: 50.0, height: 50.0)
                        
                        Spacer()
                            .frame(height: 15.0)
                        
                        Text(air.grade.airState)
                            .foregroundColor(.white)
                            .font(.body)
                    }
                }
            }
            .cornerRadius(15.0)
            .frame(width: proxy.size.width, height: proxy.size.height)
            .onAppear {
                print("air \(air.name) \(air.grade)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(initialState: WeatherViewState(), reducer: weatherReducer, environment: WeatherEnvironment(weatherService: WeatherService(), weatherConverter: WeatherConverter())))
        //AirCardView()
    }
}
