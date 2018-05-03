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
    
    lazy var viewModel: FetchRequestViewModel = {
        return FetchRequestViewModel(client: client, disposeBag: disposeBag)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        toggleButton(nextPath: nil)
        bindElementsToViewModel()
    }
    
    func bindElementsToViewModel() {
        fetchNextPath()
        fetchCode()
        incrementLabel()
        handleButtonTap()
        handleError()
    }
    
    func handleButtonTap() {
        fetchRequestButton.rx.tap
            .debounce(0.2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                guard let nextPath = self.nextPath else { return }
                self.viewModel.fetchCode(nextPath)
            }).disposed(by: disposeBag)
    }
    
    func incrementLabel() {
        viewModel.count
            .asDriver(onErrorJustReturn: 0)
            .distinctUntilChanged()
            .map { "Times Fetched: \($0)"}
            .drive(timesFetchedLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    func fetchCode() {
        viewModel.code
            .map { "Response Code \($0.response)" }
            .asDriver(onErrorJustReturn: "Response Code: Error")
            .drive(responseCodeLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    func fetchNextPath() {
        viewModel.path
            .map { $0.lastComponent() }
            .asDriver(onErrorJustReturn: nil)
            .map {
                self.nextPath = $0
                self.toggleButton(nextPath: $0)
            }
            .drive()
            .disposed(by: self.disposeBag)
    }
    
    func toggleButton(nextPath: String?) {
        fetchRequestButton.isEnabled = (nextPath != nil) ? true : false
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

