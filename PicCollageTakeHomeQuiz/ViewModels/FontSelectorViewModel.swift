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
        // The items to be displayed
        // TODO: Replaced with real items
        let items = Driver<[FontItem]>.just([
            .init(title: "HAUNTED"),
            .init(title: "Helvetica"),
        ])

        // Return the outputs
        return Outputs(
            items: items
        )
    }
}
