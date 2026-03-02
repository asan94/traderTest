//
//  TraderAPI.swift
//  TraderTest
//
//  Created by Asan Ametov on 27.02.2026.
//

import Foundation

protocol TraderAPIProtocol: AnyObject {
    func getTopQuotes(type: String, exchange: String, gainers: Int?, limit: Int?, completion: @escaping (NetworkResult<TickersDM>) -> Void)
}

class TraderAPI: BaseAPI, TraderAPIProtocol {
    
    private func request(path:Path, id:String? = nil, method:HTTPMethod, queryItems:[URLQueryItem]? = nil) -> URLRequest? {
        let path = stringFor(path: path, id: id)
        return super.request(for: path, method: method, body: nil, queryItems: queryItems) as URLRequest?
    }
    
    
    func request<T>(path:Path, id:String? = nil, method:HTTPMethod, body:T? = nil, query:[URLQueryItem]? = nil) -> URLRequest? where T : Encodable {
        let body = try? JSONEncoder().encode(body)
        let path = stringFor(path: path, id: id)
        return super.request(for: path, method: method, body: body, queryItems: query) as URLRequest?
    }
    
    //Add when we user id parametr
    private func stringFor(path:Path, id:String? = nil) -> String {
        let idmask = "{ID}"
        if let id = id {
            if path.rawValue.contains(idmask) { return path.rawValue.replacingOccurrences(of:idmask, with: id)}
            else { return (path.rawValue + "/" + id) }
        } else { return path.rawValue }
    }
    
    //Use callbacks
    func getTopQuotes(type: String, exchange: String, gainers: Int? = 0, limit: Int? = 30, completion: @escaping (NetworkResult<TickersDM>) -> Void) {
        struct Model: Codable {
            let q: Securities
            struct Securities: Codable {
                let cmd: String
                let params: [Params]
                struct Params: Codable {
                    let type: String
                    let exchange: String
                    let gainers: Int?
                    let limit: Int?
                }
            }
        }
        let model = Model(q: Model.Securities(cmd: "getTopSecurities", params: [Model.Securities.Params(type: type, exchange: exchange, gainers: gainers, limit: limit)]))
        guard let request = self.request(path: .quotes, method: .POST, body: model) else { return }
        self.perform(request) { result in
            switch result {
            case .success(let data):
                completion(data.decodeResult())
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
