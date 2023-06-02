//
//  ViewModel.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/2.
//

import Combine
import CombineDataSources

class FontSelectorViewModel {
    struct Inputs {
    }

    struct Outputs {
        // The item collection to be displayed
        let items: AnyPublisher<[FontItem], Never>
    }

    /// Binds the view model. Inputs may result in the changes to the outputs.
    /// The call site is expected to observe the outputs.
    /// - Parameter inputs: The inputs to the view model.
    /// - Returns: The outputs from the view model
    func bind(_ inputs: Inputs) -> Outputs {
        let items = CurrentValueSubject<[FontItem], Never>([])

        // Fetch the items to be displayed
        Future(manager.fetchItems)
            .sink { _ in } receiveValue: { items.send($0) }
            .store(in: &cancellables)

        // Return the outputs
        return Outputs(
            items: items.eraseToAnyPublisher()
        )
    }

    init(manager: FontManager) {
        self.manager = manager
    }

    // MARK: - Private

    private let manager: FontManager
    private var cancellables: [AnyCancellable] = []
}
