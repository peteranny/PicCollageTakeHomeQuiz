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
        // The item collection to be displayed
        let items: Driver<[FontItem]>
    }

    /// Binds the view model. Inputs may result in the changes to the outputs.
    /// The call site is expected to observe the outputs.
    /// - Parameter inputs: The inputs to the view model.
    /// - Returns: The outputs from the view model
    func bind(_ inputs: Inputs) -> Outputs {
        // Fetch the items to be displayed
        let items = manager.fetchItems().asDriver(onErrorJustReturn: []).startWith([])

        // Return the outputs
        return Outputs(
            items: items
        )
    }

    init(manager: FontManager) {
        self.manager = manager
    }

    // MARK: - Private

    private let manager: FontManager
}
