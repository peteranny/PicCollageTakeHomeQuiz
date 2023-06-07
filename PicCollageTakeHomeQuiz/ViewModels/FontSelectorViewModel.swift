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

        // The selected model
        let selectedModel: AnyPublisher<FontModel, Never>
    }

    struct Outputs {
        // Indicates if the request is ongoing
        let isLoading: AnyPublisher<Bool, Never>

        // The list of selectable categories
        let categories: AnyPublisher<[FontCategory], Never>

        // The selected category out of the selectable categories
        let selectedCategory: AnyPublisher<FontCategory, Never>

        // The model collection to be displayed
        let models: AnyPublisher<[FontModel], Never>

        // The binding to the inputs that requires the call site to manage
        let bindings: [AnyCancellable]
    }

    /// Binds the view model. Inputs may result in the changes to the outputs.
    /// The call site is expected to observe the outputs.
    /// - Parameter inputs: The inputs to the view model.
    /// - Returns: The outputs from the view model
    func bind(_ inputs: Inputs) -> Outputs {
        // Compute categories from models
        let categories: AnyPublisher<[FontCategory], Never> = modelsRelay
            .map { Set($0.map(\.item.category)).sorted() } // Get sorted distinct categories
            .map { [.all] + $0.map({ .specific($0) }) } // Always append "All" to the front
            .eraseToAnyPublisher()

        // Displays only the items that match the selected category
        let models = Publishers
            .CombineLatest3(modelsRelay, selectedCategoryRelay, selectedModelRelay)
            .map { models, category, selected in
                let models = models.map { model in
                    var model = model
                    model.selected = model.item.family == selected?.item.family
                    return model
                }
                switch category {
                case .all:
                    return models
                case .specific(let title):
                    return models.filter { $0.item.category == title }
                }
            }
            .eraseToAnyPublisher()

        // Binds the inputs
        let bindSelectedCategory = inputs.selectedCategory.sink(receiveValue: { [selectedCategoryRelay] in selectedCategoryRelay.send($0) })
        let bindSelectedModel = inputs.selectedModel.sink(receiveValue: { [selectedModelRelay] in selectedModelRelay.send($0) })
        let bindSelectedFont = inputs.selectedModel
            .flatMap { [manager] model in Future { try await manager.fetchFont(for: model.item) }.catch { _ in Empty() } }
            .sink { [fontObserver] in _ = fontObserver.receive($0) }

        // Return the outputs
        return Outputs(
            isLoading: isLoadingRelay.eraseToAnyPublisher(),
            categories: categories,
            selectedCategory: selectedCategoryRelay.eraseToAnyPublisher(),
            models: models,
            bindings: [
                bindSelectedCategory,
                bindSelectedModel,
                bindSelectedFont,
            ]
        )
    }

    init(manager: FontManaging, fontObserver: AnySubscriber<String, Never>) {
        self.manager = manager
        self.fontObserver = fontObserver

        // Fetch the items to be displayed
        Future(manager.fetchItems)
            .map { items -> [FontModel] in
                return items.map { item in
                    // Form the model with drivers
                    return FontModel(
                        item: item,
                        menu: manager.menuDriver(for: item),
                        state: manager.fontStateDriver(for: item),
                        selected: false
                    )
                }
            }
            .handleEvents(receiveSubscription: { [isLoadingRelay] _ in
                isLoadingRelay.send(true)
            }, receiveCompletion: { [isLoadingRelay] _ in
                isLoadingRelay.send(false)
            })
            .sink { _ in } receiveValue: { [modelsRelay] in modelsRelay.send($0) }
            .store(in: &cancellables)
    }

    // MARK: - Private

    private let manager: FontManaging
    private let fontObserver: AnySubscriber<String, Never>
    private let isLoadingRelay = CurrentValueSubject<Bool, Never>(false)
    private let modelsRelay = CurrentValueSubject<[FontModel], Never>([])
    private let selectedCategoryRelay = CurrentValueSubject<FontCategory, Never>(.all)
    private let selectedModelRelay = CurrentValueSubject<FontModel?, Never>(nil)
    private var cancellables: [AnyCancellable] = []
}
