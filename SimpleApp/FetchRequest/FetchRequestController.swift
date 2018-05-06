//
//  FetchRequestController.swift
//  SimpleApp
//
//  Created by Muhammad Moaz on 5/3/18.
//  Copyright © 2018 Muhammad Moaz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FetchRequestController: UIViewController {
    
    @IBOutlet weak var responseCodeLabel: UILabel!
    @IBOutlet weak var timesFetchedLabel: UILabel!
    @IBOutlet weak var fetchRequestButton: UIButton!

    private (set) var client = SimpleAppClient()
    private (set) var disposeBag = DisposeBag()
    private (set) var nextPath: String?
    
    private lazy var viewModel: FetchRequestViewModel = {
        return FetchRequestViewModel(client: client, disposeBag: disposeBag)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        fetchRequestButton.isEnabled = false
        bindElementsToViewModel()
    }
    
    func bindElementsToViewModel() {
        bindNextPath()
        bindResponseCodeLabel()
        bindTimesFetchedLabel()
        handleButtonTap()
        handleError()
    }
    
    func handleButtonTap() {
        fetchRequestButton.rx.tap
            .debounce(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                guard let nextPath = self.nextPath else { return }
                self.viewModel.fetchCode(nextPath)
            }).disposed(by: disposeBag)
    }
}

extension FetchRequestController {
    func bindNextPath() {
        viewModel.fetchNextPath()
        viewModel.path
            .map { $0.lastComponent() }
            .asDriver(onErrorJustReturn: nil)
            .drive(onNext: { [unowned self] path in
                self.nextPath = path
                self.fetchRequestButton.isEnabled = (path != nil) ? true : false
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindTimesFetchedLabel() {
        viewModel.count
            .asDriver(onErrorJustReturn: 0)
            .distinctUntilChanged()
            .map { "Times Fetched: \($0)"}
            .drive(timesFetchedLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    func bindResponseCodeLabel() {
        viewModel.code
            .map { "Response Code \($0.response)" }
            .asDriver(onErrorJustReturn: "Response Code: Error")
            .drive(responseCodeLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    func handleError() {
        viewModel.error.map {
            $0.localizedDescription
            }.subscribe(onNext: { [unowned self] error in
                UIAlertController.presentDefault(with: "Error", message: error, in: self)
            })
        .disposed(by: self.disposeBag)
    }
}

