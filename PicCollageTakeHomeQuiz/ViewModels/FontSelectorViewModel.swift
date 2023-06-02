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
        // The list of selectable categories
        let categories: AnyPublisher<[FontCategory], Never>

        // The item collection to be displayed
        let items: AnyPublisher<[FontItem], Never>
    }

    /// Binds the view model. Inputs may result in the changes to the outputs.
    /// The call site is expected to observe the outputs.
    /// - Parameter inputs: The inputs to the view model.
    /// - Returns: The outputs from the view model
    func bind(_ inputs: Inputs) -> Outputs {
        // Compute categories from items
        let categories: AnyPublisher<[FontCategory], Never> = itemsRelay
            .map { Set($0.map(\.category)).sorted() } // Get sorted distinct categories
            .map { [.all] + $0.map({ .specific($0) }) } // Always append "All" to the front
            .eraseToAnyPublisher()

        // Return the outputs
        return Outputs(
            categories: categories,
            items: itemsRelay.eraseToAnyPublisher()
        )
    }

    init(manager: FontManager) {
        self.manager = manager

        // Fetch the items to be displayed
        Future(manager.fetchItems)
            .sink { _ in } receiveValue: { [itemsRelay] in itemsRelay.send($0) }
            .store(in: &cancellables)
    }

    // MARK: - Private

    private let manager: FontManager
    private let itemsRelay = CurrentValueSubject<[FontItem], Never>([])
    private var cancellables: [AnyCancellable] = []
}
