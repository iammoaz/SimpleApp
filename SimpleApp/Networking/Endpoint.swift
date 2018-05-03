//
//  Endpoint.swift
//  SimpleApp
//
//  Created by Muhammad Moaz on 5/3/18.
//  Copyright © 2018 Muhammad Moaz. All rights reserved.
//

import Foundation

protocol Endpoint {
    var base: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
}

extension Endpoint {
    var urlComponents: URLComponents {
        var components = URLComponents(string: base)!
        components.path = path
        components.queryItems = queryItems
        
        return components
    }
    
    var request: URLRequest {
        let url = urlComponents.url!
        return URLRequest(url: url)
    }
}

enum SimpleApp {
    case root
    case code(String)
}

extension SimpleApp: Endpoint {
    var base: String {
        return "http://localhost:8000"
    }
    
    var path: String {
        switch self {
        case .root:
            return "/"
        case .code(let path):
            return "/\(path)/"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        default:
            return []
        }
    }
}

