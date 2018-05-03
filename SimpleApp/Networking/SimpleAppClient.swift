//
//  SimpleAppClient.swift
//  SimpleApp
//
//  Created by Muhammad Moaz on 5/3/18.
//  Copyright © 2018 Muhammad Moaz. All rights reserved.
//

import Foundation
import RxSwift

final class SimpleAppClient: APIClient {
    
    internal let session: URLSession
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .ephemeral)
    }
}

extension SimpleAppClient {
    func nextPath() -> Single<Path> {
        let endpoint = SimpleApp.root
        return fetch(with: endpoint)
    }
    
    func code(for path: String) -> Single<Code> {
        let endpoint = SimpleApp.code(path)
        return fetch(with: endpoint)
    }
}
