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
        // The changes to the selected category
        let selectedCategory: Observable<FontCategory>
    }

    struct Outputs {
        // The list of selectable categories
        let categories: Driver<[FontCategory]>

        // The selected category out of the selectable categories
        let selectedCategory: Driver<FontCategory>

        // The item collection to be displayed
        let items: Driver<[FontItem]>

        // The binding to the inputs that requires the call site to manage
        let bindings: Disposable
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

        // Displays only the items that match the selected category
        let items = Driver
            .combineLatest(itemsRelay.asDriver(), selectedCategoryRelay.asDriver())
            .map { items, category in
                switch category {
                case .all:
                    return items
                case .specific(let title):
                    return items.filter { $0.category == title }
                }
            }

        // Binds the inputs
        let bindSelectedCategory = inputs.selectedCategory.bind(to: selectedCategoryRelay)

        // Return the outputs
        return Outputs(
            categories: categories,
            selectedCategory: selectedCategoryRelay.asDriver(),
            items: items,
            bindings: bindSelectedCategory
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
    private let selectedCategoryRelay = BehaviorRelay<FontCategory>(value: .all)
    private let disposeBag = DisposeBag()
}
