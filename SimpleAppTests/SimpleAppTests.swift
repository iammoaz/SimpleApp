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
    
    private var client: SimpleAppClient!
    private var disposeBag: DisposeBag!
    
    private var scheduler: TestScheduler!
    private var testObserver: TestableObserver<String>!
    
    var path: Path? = nil
    var code: Code? = nil
    var error: APIError? = nil
    
    lazy var viewModel: FetchRequestViewModel = {
        return FetchRequestViewModel(client: self.client, disposeBag: self.disposeBag)
    }()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        client = SimpleAppClient()
        disposeBag = DisposeBag()
        
        scheduler = TestScheduler(initialClock: 0)
        testObserver = scheduler.createObserver(String.self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    
    func testNextPath() {
        let path = viewModel.path.map { path in
            return path.next
        }
        
        XCTAssertNotNil(path)
    }
    
    func testErrorOnInvalidNextPath() {
        client.code(for: "code").subscribe { [unowned self] event in
            switch event {
            case .success(let code):
                self.code = code
                expect
            case .error(let error):
                let apiError = error as! APIError
                self.error = apiError
            }
        }.disposed(by: disposeBag)
    
        
        let pred = NSPredicate(format: "code != nil")
        let exp = expectation(for: pred, evaluatedWith: self, handler: nil)
        let res = XCTWaiter.wait(for: [exp], timeout: 5.0)
        
        if res == XCTWaiter.Result.completed {
            XCTAssertNotNil(code)
        }
    }
    
    func testLastComponentPathIsComputed() {
        let path = Path(next: "http://localhost:8000/1246efe3-4f8a-11e8-8aa8-d6002c990601/")
        let lastPath = path.lastComponent()
        
        XCTAssertEqual(lastPath, "1246efe3-4f8a-11e8-8aa8-d6002c990601")
    }
}
