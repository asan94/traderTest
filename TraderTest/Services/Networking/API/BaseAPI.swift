//
//  BaseAPI.swift
//  TraderTest
//
//  Created by Asan Ametov on 27.02.2026.
//

import Foundation

enum HTTPMethod: String, Codable {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
}

class BaseAPI: NSObject {
    private let baseURL = "tradernet.com"
    
    func perform(_ request: URLRequest, completionHandler callback: @escaping (Result<Data, Error>) -> Void){
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                callback(.failure(error))
            } else if let data = data {
                if let error = data.jsonDecode(typeOf: ErrorDM.self) {
                    callback(.failure(error.asNSError()))
                } else {
                    callback(.success(data))
                }
            }
        }.resume()
    }

    nonisolated func perform<T: Decodable>(_ request: URLRequest, decodeType: T.Type) async -> NetworkResult<T> {
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return data.decodeResultConcurrency()
        } catch {
            return .failure(error)
        }
    }

    func request(for apiPath: String, method: HTTPMethod, body: Data?, queryItems:[URLQueryItem]?) -> URLRequest?{
        return requestForApiPath(path: apiPath, host: self.baseURL, method: method, body: body, queryItems: queryItems)
    }
    
    func requestForApiPath(path: String, host:String, method: HTTPMethod, body: Data?, queryItems:[URLQueryItem]?) -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path
        if let queryItems = queryItems {
            components.queryItems = queryItems
        }
        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        if let body = body {
            request.httpBody = body
        }
        return request
    }
    
    @objc func printPrettyJson(data: Data?) {
        #if DEBUG
        guard let data = data else { print("Data is nil"); return }
        guard let object = try? JSONSerialization.jsonObject(with: data, options: []) else { print("Failed to serialize json"); return }
        
        if let tempData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
           let prettyPrintedString = NSString(data: tempData, encoding: String.Encoding.utf8.rawValue) {
            print(prettyPrintedString)
        }
        #endif
    }
    
    func printRawData(data:Data?){
        #if DEBUG
        if let data = data, let str = String(data: data, encoding: .utf8) {
            print(str)
        } else{
            print("Data is nil")
        }
        #endif
    }
    
}
