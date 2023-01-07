//
//  WeatherModel.swift
//  TodayAir
//
//  Created by 김동준 on 2022/12/24.
//

import Foundation

struct WeatherModel: Codable {
    let response: Response
}

struct Response: Codable {
    let body: Body
}

struct Body: Codable {
    let totalCount: Int
    let items: [WeatherDTO]
    let pageNo, numOfRows: Int
}

struct WeatherDTO: Codable {
    let so2Grade: String?
    let khaiValue, so2Value, coValue: String?
    let o3Grade, pm10Value, khaiGrade, pm25Value: String?
    let sidoName: String?
    let no2Grade: String?
    let pm25Grade: String?
    let dataTime: String?
    let coGrade, no2Value, stationName, pm10Grade: String?
    let o3Value: String?
}
