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
            
            if httpResponse.statusCode == 200 {
                if let data = data {
                    completion(data, nil)
                } else {
                    completion(nil, .invalidData)
                }
                
            } else {
                completion(nil, .responseUnsuccessful)
            }
        }
        
        return task
    }
    
    func fetch<T: Decodable>(with endpoint: Endpoint) -> Single<T> {
        return Single<T>.create { single in
            let task = self.dataTask(with: endpoint.request) { (data, error) in
                guard let data = data else {
                    single(.error(APIError.invalidData))
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

