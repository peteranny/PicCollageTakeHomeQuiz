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
        // The changes to the selected category
        let selectedCategory: AnyPublisher<FontCategory, Never>
    }

    struct Outputs {
        // The list of selectable categories
        let categories: AnyPublisher<[FontCategory], Never>

        // The selected category out of the selectable categories
        let selectedCategory: AnyPublisher<FontCategory, Never>

        // The item collection to be displayed
        let items: AnyPublisher<[FontItem], Never>

        // The binding to the inputs that requires the call site to manage
        let bindings: [AnyCancellable]
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

        // Displays only the items that match the selected category
        let items = Publishers
            .CombineLatest(itemsRelay, selectedCategoryRelay)
            .map { items, category in
                switch category {
                case .all:
                    return items
                case .specific(let title):
                    return items.filter { $0.category == title }
                }
            }
            .eraseToAnyPublisher()

        // Binds the inputs
        let bindSelectedCategory = inputs.selectedCategory.sink(receiveValue: { [selectedCategoryRelay] in selectedCategoryRelay.send($0) })

        // Return the outputs
        return Outputs(
            categories: categories,
            selectedCategory: selectedCategoryRelay.eraseToAnyPublisher(),
            items: items,
            bindings: [bindSelectedCategory]
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
    private let selectedCategoryRelay = CurrentValueSubject<FontCategory, Never>(.all)
    private var cancellables: [AnyCancellable] = []
}
