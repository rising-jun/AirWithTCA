//
//  WeatherRepository.swift
//  TodayAir
//
//  Created by 김동준 on 2022/12/24.
//

import Foundation


final class WeatherService {
    func request(api: WeatherAPI) async -> Result<WeatherDTO, NetworkError> {
        return await withCheckedContinuation { continuation in
            guard var urlComponents = URLComponents(string: api.baseURL) else {
                return continuation.resume(returning: .failure(.invailedURL))
            }
            
            if let parameter = api.parameter {
                var queryItems = [URLQueryItem]()
                for key in parameter.keys {
                    if let value = parameter[key] as? String {
                        queryItems.append(URLQueryItem(name: key, value: value))
                    }
                }
                urlComponents.queryItems = queryItems
            }
            
            let urlString = api.baseURL + "?" + "\(urlComponents.query ?? "")"
            guard let url = URL(string: urlString) else {
                return continuation.resume(returning: .failure(.invailedURL))
            }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("error \(error)")
                    return continuation.resume(returning: .failure(.taskStatus)) }
                guard let data = data else { return continuation.resume(returning: .failure(.nilData)) }
                guard let dto = try? JSONDecoder().decode(WeatherModel.self, from: data) else { return continuation.resume(returning: .failure(.parsing)) }
                guard let weatherDTO = dto.response.body.items.first else { return continuation.resume(returning: .failure(.nilData))}
                continuation.resume(returning: .success(weatherDTO))
            }
            task.resume()
        }
    }
}

enum NetworkError: Error {
    case invailedURL
    case taskStatus
    case nilData
    case parsing
}

enum WeatherAPI {
    case fetchWeather
}
extension WeatherAPI: BaseAPI {
    var baseURL: String {
        return "https://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getCtprvnRltmMesureDnsty"
    }
    
    var method: Method {
        switch self {
        case .fetchWeather:
            return .get
        }
    }
    
    var parameter: [String : Any]? {
        return ["serviceKey": "8KMZQMPCBSiU%2F6nqRFH1iBw9BH9Ww2xgitwSo3yy5FIEOyfEFxiyeExpay9ZucnXtW%2BcrMmdXakp815ZYnEmHg%3D%3D",
                "returnType": "json",
                "numOfRows": "5",
                "pageNo": "1",
                "sidoName": "서울".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                "ver": "1.0"
        ]
    }
}

protocol BaseAPI {
    var baseURL: String { get }
    var method: Method { get }
    var parameter: [String: Any]? { get }
}

enum Method {
    case get
    case post
}
extension Method {
    var value: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        }
    }
}
