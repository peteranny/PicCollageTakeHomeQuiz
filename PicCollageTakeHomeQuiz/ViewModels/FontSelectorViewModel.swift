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

        // The selected model
        let selectedModel: Observable<FontModel>
    }

    struct Outputs {
        // The list of selectable categories
        let categories: Driver<[FontCategory]>

        // The selected category out of the selectable categories
        let selectedCategory: Driver<FontCategory>

        // The model collection to be displayed
        let models: Driver<[FontModel]>

        // The binding to the inputs that requires the call site to manage
        let bindings: Disposable
    }

    /// Binds the view model. Inputs may result in the changes to the outputs.
    /// The call site is expected to observe the outputs.
    /// - Parameter inputs: The inputs to the view model.
    /// - Returns: The outputs from the view model
    func bind(_ inputs: Inputs) -> Outputs {
        // Compute categories from models
        let categories: Driver<[FontCategory]> = modelsRelay.asDriver()
            .map { Set($0.map(\.item.category)).sorted() } // Get sorted distinct categories
            .map { [.all] + $0.map({ .specific($0) }) } // Always append "All" to the front

        // Displays only the items that match the selected category
        let models = Driver
            .combineLatest(modelsRelay.asDriver(), selectedCategoryRelay.asDriver())
            .map { models, category in
                switch category {
                case .all:
                    return models
                case .specific(let title):
                    return models.filter { $0.item.category == title }
                }
            }

        // Binds the inputs
        let bindSelectedCategory = inputs.selectedCategory.bind(to: selectedCategoryRelay)
        let bindSelectedFont = inputs.selectedModel
            .flatMapLatest { [manager] model in manager.fetchFont(for: model.item) }
            .bind(to: fontObserver)

        // Return the outputs
        return Outputs(
            categories: categories,
            selectedCategory: selectedCategoryRelay.asDriver(),
            models: models,
            bindings: Disposables.create(
                bindSelectedCategory,
                bindSelectedFont
            )
        )
    }

    init(manager: FontManager, fontObserver: AnyObserver<String>) {
        self.manager = manager
        self.fontObserver = fontObserver

        // Fetch the items to be displayed
        manager
            .fetchItems()
            .map { items -> [FontModel] in
                return items.map { item in
                    // Form the model with drivers
                    return FontModel(
                        item: item,
                        menu: manager.menuDriver(for: item),
                        state: manager.fontStateDriver(for: item)
                    )
                }
            }
            .asObservable()
            .bind(to: modelsRelay)
            .disposed(by: disposeBag)
    }

    // MARK: - Private

    private let manager: FontManager
    private let fontObserver: AnyObserver<String>
    private let modelsRelay = BehaviorRelay<[FontModel]>(value: [])
    private let selectedCategoryRelay = BehaviorRelay<FontCategory>(value: .all)
    private let disposeBag = DisposeBag()
}
