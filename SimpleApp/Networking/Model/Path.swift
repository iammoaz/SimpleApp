//
//  Path.swift
//  SimpleApp
//
//  Created by Muhammad Moaz on 5/3/18.
//  Copyright © 2018 Muhammad Moaz. All rights reserved.
//

import Foundation

struct Path: Decodable {
    private (set) var next: String
    
    private enum CodingKeys: String, CodingKey {
        case next = "next_path"
    }
    
    func lastComponent() -> String {
        guard let url = URL(string: next) else { return "" }
        return url.lastPathComponent
    }
}
