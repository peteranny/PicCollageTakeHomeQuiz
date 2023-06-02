//
//  ViewModel.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/2.
//

import RxCocoa
import RxSwift

class FontSelectorViewModel {
    struct Inputs {
    }

    struct Outputs {
        // The list of selectable categories
        let categories: Driver<[FontCategory]>

        // The item collection to be displayed
        let items: Driver<[FontItem]>
    }

    /// Binds the view model. Inputs may result in the changes to the outputs.
    /// The call site is expected to observe the outputs.
    /// - Parameter inputs: The inputs to the view model.
    /// - Returns: The outputs from the view model
    func bind(_ inputs: Inputs) -> Outputs {
        // Compute categories from items
        let categories: Driver<[FontCategory]> = itemsRelay.asDriver()
            .map { Set($0.map(\.category)).sorted() } // Get sorted distinct categories
            .map { [.all] + $0.map({ .specific($0) }) } // Always append "All" to the front

        // Return the outputs
        return Outputs(
            categories: categories,
            items: itemsRelay.asDriver()
        )
    }

    init(manager: FontManager) {
        self.manager = manager

        // Fetch the items to be displayed
        manager.fetchItems().asObservable().bind(to: itemsRelay).disposed(by: disposeBag)
    }

    // MARK: - Private

    private let manager: FontManager
    private let itemsRelay = BehaviorRelay<[FontItem]>(value: [])
    private let disposeBag = DisposeBag()
}
