//
//  FetchRequestViewModel.swift
//  SimpleApp
//
//  Created by Muhammad Moaz on 5/3/18.
//  Copyright © 2018 Muhammad Moaz. All rights reserved.
//

import Foundation
import RxSwift

class FetchRequestViewModel {
    
    private (set) var client: SimpleAppClient
    private (set) var disposeBag: DisposeBag
    
    private (set) var pathSubject = PublishSubject<Path>()
    private (set) var codeSubject = PublishSubject<Code>()
    private (set) var countObject = Variable<Int>(0)
    private (set) var errorSubject = PublishSubject<APIError>()
    
    lazy var path: Observable<Path> = {
        return self.pathSubject.asObservable()
    }()
    
    lazy var code: Observable<Code> = {
        return self.codeSubject.asObservable()
    }()
    
    lazy var count: Observable<Int> = {
        return self.countObject.asObservable()
    }()
    
    lazy var error: Observable<APIError> = {
        return self.errorSubject.asObservable()
    }()
    
    init(client: SimpleAppClient, disposeBag: DisposeBag) {
        self.client = client
        self.disposeBag = disposeBag
    }
    
    func fetchNextPath() {
        client.nextPath().subscribe { [unowned self] event in
            switch event {
            case .success(let path):
                self.pathSubject.onNext(path)
            case .error(let error):
                let apiError = error as! APIError
                self.errorSubject.onNext(apiError)
                print(apiError.localizedDescription)
            }
        }.disposed(by: disposeBag)
    }
    
    func fetchCode(_ code: String) {
        client.code(for: code).subscribe { [unowned self] event in
            switch event {
            case .success(let code):
                self.codeSubject.onNext(code)
                self.countObject.value += 1
            case .error(let error):
                let apiError = error as! APIError
                self.errorSubject.onNext(apiError)
                print(apiError.localizedDescription)
            }
        }.disposed(by: disposeBag)
    }
}
