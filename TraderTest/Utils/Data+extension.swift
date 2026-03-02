//
//  Data+extension.swift
//  TraderTest
//
//  Created by Asan Ametov on 27.02.2026.
//

import Foundation

enum NetworkResult<T> {
    case success(T)
    case failure(Error)
}

extension Data {
    
    func jsonDecode<T>(typeOf:T.Type) -> T? where T : Decodable {
        return try? JSONDecoder().decode(typeOf, from: self)
    }
    
    func jsonDecode<T>(typeOf:[T].Type, errorString: inout NSError?) -> [T]? where T : Decodable & DecoderProvider {
        return try? T.decoder().decode(typeOf, from: self)
    }
    
    func decodeResult<T: Decodable>() -> NetworkResult<T> {
        do {
            return .success(try JSONDecoder().decode(T.self, from: self))
        } catch {
            return .failure(error)
        }
    }
    
    nonisolated func decodeResultConcurrency<T: Decodable>() -> NetworkResult<T> {
         do {
             return .success(try JSONDecoder().decode(T.self, from: self))
         } catch {
             return .failure(error)
         }
     }
    
    //to show error
    func decodingErrorOf<T>(type:T, error:Error, nserror: inout NSError?) where T : Any {
    
        let description = error.localizedDescription + " (\(String(describing:type)))"
        if let decodingError = error as? DecodingError {
            switch decodingError {
              case .typeMismatch(let key, let value):
                print("error \(key), value \(value) and ERROR: \(error.localizedDescription)")
              case .valueNotFound(let key, let value):
                print("error \(key), value \(value) and ERROR: \(error.localizedDescription)")
              case .keyNotFound(let key, let value):
                print("error \(key), value \(value) and ERROR: \(error.localizedDescription)")
              case .dataCorrupted(let key):
                print("error \(key), and ERROR: \(error.localizedDescription)")
              default:
                print("ERROR: \(error.localizedDescription)")
              }
        }
        //TODO: added error coding key to description
        
        nserror = NSError(domain:"", code: 0, userInfo: [ NSLocalizedDescriptionKey:description])
    }

    func jsonDecode<T>(typeOf:T.Type, errorString: inout NSError?) -> NetworkResult<T> where T : Decodable {
        do {
            return .success(try JSONDecoder().decode(typeOf, from: self))
        } catch {
            return .failure(decodingErrorOf(type: T.self, error: error, nserror: &errorString) as? Error ?? NSError())
        }
    }
//    func jsonDecode<T>(typeOf:[T].Type, errorString: inout NSError?) -> NetworkResult<T> where T : Decodable {
//        do {
//            return .success(try T.decoder().decode(typeOf, from: self))
//        } catch {
//            return .failure(decodingErrorOf(type: T.self, error: error, nserror: &errorString) as? Error ?? NSError())
//        }
//    }
}
