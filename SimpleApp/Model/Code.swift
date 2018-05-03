//
//  Code.swift
//  SimpleApp
//
//  Created by Muhammad Moaz on 5/3/18.
//  Copyright © 2018 Muhammad Moaz. All rights reserved.
//

import Foundation

struct Code: Decodable {
    private (set) var path: String
    private (set) var response: String
    
    private enum CodingKeys: String, CodingKey {
        case path = "path"
        case response = "response_code"
    }
}
