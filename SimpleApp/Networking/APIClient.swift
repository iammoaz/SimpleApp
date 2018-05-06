//
//  APIClient.swift
//  SimpleApp
//
//  Created by Muhammad Moaz on 5/3/18.
//  Copyright © 2018 Muhammad Moaz. All rights reserved.
//

import Foundation
import RxSwift

enum APIError: Error {
    case requestFailed
    case jsonConversionFailure
    case invalidData
    case responseUnsuccessful
    case jsonParsingFailure
    case message(error: String)
    
    var localizedDescription: String {
        switch self {
        case .requestFailed:
            return "Request Failed"
        case .invalidData:
            return "Invalid Data"
        case .responseUnsuccessful:
            return "Response Unsuccessful"
        case .jsonParsingFailure:
            return "JSON Parsing Failure"
        case .jsonConversionFailure:
            return "JSON Conversion Failure"
        case .message(let error):
            return error
        }
    }
}

protocol APIClient {
    var session: URLSession { get }
    func fetch<T: Decodable>(with endpoint: Endpoint) -> Single<T>
}

extension APIClient {
    typealias dataTaskCompletionHandler = (Data?, APIError?) -> Void
    
    func dataTask(with request: URLRequest, completion: @escaping dataTaskCompletionHandler) -> URLSessionDataTask {
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, .requestFailed)
                return
            }
            
            guard let data = data else {
                completion(nil, .invalidData)
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                completion(data, nil)
                
            case 400:
                do {
                    let jsonError = try JSONSerialization.jsonObject(with: data, options: []) as! [String: String]
                    let errorMessage = jsonError["error"] as String?
                    completion(nil, .message(error: errorMessage!))
                } catch {
                    completion(nil, .jsonParsingFailure)
                }
                
            default:
                completion(nil, .responseUnsuccessful)
            }
        }
        
        return task
    }
    
    func fetch<T: Decodable>(with endpoint: Endpoint) -> Single<T> {
        return Single<T>.create { single in
            let task = self.dataTask(with: endpoint.request) { (data, error) in
                guard let data = data else {
                    single(.error(APIError.message(error: error!.localizedDescription)))
                    return
                }
                
                do {
                    let model: T = try JSONDecoder().decode(T.self, from: data)
                    single(.success(model))
                } catch {
                    single(.error(APIError.jsonConversionFailure))
                }
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

