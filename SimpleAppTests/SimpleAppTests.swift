//
//  SimpleAppTests.swift
//  SimpleAppTests
//
//  Created by Muhammad Moaz on 5/3/18.
//  Copyright © 2018 Muhammad Moaz. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

@testable import SimpleApp

class SimpleAppTests: XCTestCase {
    
    private var client = SimpleAppClient()
    private var disposeBag = DisposeBag()
    
    lazy var viewModel: FetchRequestViewModel = {
        return FetchRequestViewModel(client: self.client, disposeBag: self.disposeBag)
    }()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFetchNextPath() {
        viewModel.fetchNextPath()
        
        let expect = expectation(description: #function)
        var path: String? = nil
        
        viewModel.path.asObservable().subscribe(onNext: {
            path = $0.next
            expect.fulfill()
        }).disposed(by: self.disposeBag)
        
        waitForExpectations(timeout: 1.0) { error in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
        }
        
        XCTAssertNotNil(path)
    }
    
    func testErrorOnInvalidNextPath() {
        let expect = expectation(description: #function)
        var errorString: String? = nil
        
        viewModel.fetchCode("a6f53f2b-5128-11e8-b520-d6002c990601")
        viewModel.error.asObservable().subscribe(onNext: {
            errorString = $0.localizedDescription
            expect.fulfill()
        }).disposed(by: self.disposeBag)
        
        waitForExpectations(timeout: 1.0)
        XCTAssertNotNil(errorString)
    }
    
    func testValidResponseCode() {
        let expect = expectation(description: #function)
        var responseCode: String? = nil
        var errorString: String? = nil
        
        client.nextPath().flatMap {
            self.client.code(for: $0.lastComponent())
            }.subscribe(onSuccess: { (code) in
                responseCode = code.response
                expect.fulfill()
            }) { (error) in
                errorString = error.localizedDescription
        }.disposed(by: self.disposeBag)
        
        waitForExpectations(timeout: 1.0)
        XCTAssertNotNil(responseCode)
        XCTAssertNil(errorString)
    }
    
    func testLastComponentPathIsComputed() {
        let path = Path(next: "http://localhost:8000/1246efe3-4f8a-11e8-8aa8-d6002c990601/iamthelastpath/")
        let lastPath = path.lastComponent()
        
        XCTAssertEqual(lastPath, "iamthelastpath")
    }
}
