//
//  FontSelectorViewModelTests.swift
//  PicCollageTakeHomeQuizTests
//
//  Created by Peteranny on 2023/6/7.
//

import Combine
import Entwine
import EntwineTest
import XCTest
@testable import PicCollageTakeHomeQuiz

class FontSelectorViewModelTests: XCTestCase {
    /// Test if `outputs.isLoading` responds to the request
    func test_isLoading() {
        // Set up dependencies
        let manager = FontManager.mock(fetchedAtOnce: false)
        let viewModel = FontSelectorViewModel.mock(manager: manager)

        // Set up inputs / outputs
        let inputs = FontSelectorViewModel.Inputs.mock()
        let outputs = viewModel.bind(inputs)

        // Bind observers
        let loadingObserver = ReplaySubject<Bool, Never>.createUnbounded()
        var cancellables: [AnyCancellable] = []
        cancellables.append(contentsOf: outputs.bindings)
        cancellables.append(outputs.isLoading.sink { loadingObserver.send($0) })

        // Start steps
        let scheduler = TestScheduler(initialClock: .zero)
        let results = scheduler.start {
            manager.fetchDone()
            return loadingObserver
        }

        // Verify the result
        XCTAssertEqual(results.recordedOutput, [
            (200, .subscription),
            (200, .input(true)),
            (200, .input(false)),
        ])
    }

    /// Test if `outputs.categories` matches the fetched font items
    func test_categories() {
        // Set up dependencies
        let items: [FontItem] = [
            FontItem.mock(category: "a"),
            FontItem.mock(category: "b"),
        ]
        let manager = FontManager.mock(fetchedItems: items)
        let viewModel = FontSelectorViewModel.mock(manager: manager)

        // Set up inputs / outputs
        let inputs = FontSelectorViewModel.Inputs.mock()
        let outputs = viewModel.bind(inputs)

        // Bind observers
        let categoriesObserver = ReplaySubject<[FontCategory], Never>.createUnbounded()
        var cancellables: [AnyCancellable] = []
        cancellables.append(contentsOf: outputs.bindings)
        cancellables.append(outputs.categories.sink { categoriesObserver.send($0) })

        // Start steps
        let scheduler = TestScheduler(initialClock: .zero)
        let results = scheduler.start {
            return categoriesObserver
        }

        // Verify the result
        XCTAssertEqual(results.recordedOutput, [
            (200, .subscription),
            (200, .input([.all, .specific("a"), .specific("b")])),
        ])
    }

    /// Test if `outputs.selectedCategory` responds to the inputs
    func test_selectedCategory() {
        // Set up dependencies
        let items: [FontItem] = [
            FontItem.mock(category: "a"),
            FontItem.mock(category: "b"),
        ]
        let manager = FontManager.mock(fetchedItems: items)
        let viewModel = FontSelectorViewModel.mock(manager: manager)

        // Set up inputs / outputs
        let selectedCategory = PassthroughSubject<FontCategory, Never>()
        let inputs = FontSelectorViewModel.Inputs.mock(
            selectedCategory: selectedCategory.eraseToAnyPublisher()
        )
        let outputs = viewModel.bind(inputs)

        // Bind observers
        let selectedCategoryObserver = ReplaySubject<FontCategory, Never>.createUnbounded()
        var cancellables: [AnyCancellable] = []
        cancellables.append(contentsOf: outputs.bindings)
        cancellables.append(outputs.selectedCategory.sink { selectedCategoryObserver.send($0) })

        // Start steps
        let scheduler = TestScheduler(initialClock: .zero)
        let results = scheduler.start {
            selectedCategory.send(.specific("b"))
            selectedCategory.send(.specific("a"))
            selectedCategory.send(.all)
            return selectedCategoryObserver
        }

        // Verify the result
        XCTAssertEqual(results.recordedOutput, [
            (200, .subscription),
            (200, .input(.all)),
            (200, .input(.specific("b"))),
            (200, .input(.specific("a"))),
            (200, .input(.all)),
        ])
    }

    /// Test if `outputs.models` emits the models that match the selected category
    func test_models() {
        // Set up dependencies
        let items: [FontItem] = [
            FontItem.mock(family: "1", category: "a"),
            FontItem.mock(family: "2", category: "b"),
        ]
        let manager = FontManager.mock(fetchedItems: items)
        let viewModel = FontSelectorViewModel.mock(manager: manager)

        // Set up inputs / outputs
        let selectedCategory = PassthroughSubject<FontCategory, Never>()
        let inputs = FontSelectorViewModel.Inputs.mock(
            selectedCategory: selectedCategory.eraseToAnyPublisher()
        )
        let outputs = viewModel.bind(inputs)

        // Bind observers
        let familiesObserver = ReplaySubject<[String], Never>.createUnbounded()
        var cancellables: [AnyCancellable] = []
        cancellables.append(contentsOf: outputs.bindings)
        cancellables.append(outputs.models.map({ $0.map(\.item.family) }).sink { familiesObserver.send($0) })

        // Start steps
        let scheduler = TestScheduler(initialClock: .zero)
        let results = scheduler.start {
            selectedCategory.send(.specific("a"))
            selectedCategory.send(.all)
            return familiesObserver
        }

        // Verify the result
        XCTAssertEqual(results.recordedOutput, [
            (200, .subscription),
            (200, .input(["1", "2"])),
            (200, .input(["1"])),
            (200, .input(["1", "2"])),
        ])
    }

    /// Test if `outputs.models` emits the models selected by the inputs
    func test_selectedModel() {
        // Set up dependencies
        let items: [FontItem] = [
            FontItem.mock(family: "1"),
            FontItem.mock(family: "2"),
        ]
        let manager = FontManager.mock(fetchedItems: items)
        let viewModel = FontSelectorViewModel.mock(manager: manager)

        // Set up inputs / outputs
        let selectedModel = PassthroughSubject<FontModel, Never>()
        let inputs = FontSelectorViewModel.Inputs.mock(
            selectedModel: selectedModel.eraseToAnyPublisher()
        )
        let outputs = viewModel.bind(inputs)

        // Bind observers
        let selectedObserver = ReplaySubject<[Bool], Never>.createUnbounded()
        var cancellables: [AnyCancellable] = []
        cancellables.append(contentsOf: outputs.bindings)
        cancellables.append(outputs.models.map({ $0.map(\.selected) }).sink { selectedObserver.send($0) })

        // Start steps
        let scheduler = TestScheduler(initialClock: .zero)
        let results = scheduler.start {
            let models = self.getModels(from: outputs, cancellables: &cancellables)
            selectedModel.send(models[0])
            selectedModel.send(models[1])
            return selectedObserver
        }

        // Verify the result
        XCTAssertEqual(results.recordedOutput, [
            (200, .subscription),
            (200, .input([false, false])),
            (200, .input([true, false])),
            (200, .input([false, true])),
        ])
    }

    /// Test if `fontObserver` emits the font for the selected and downloaded font
    func test_fontObserver() {
        // Set up dependencies
        let item = FontItem.mock(family: "1")
        let manager = FontManager.mock(fetchedItems: [item])
        let fontObserver = ReplaySubject<String, Never>.createUnbounded()
        let viewModel = FontSelectorViewModel.mock(manager: manager, fontObserver: AnySubscriber(receiveValue: {
            fontObserver.send($0)
            return .unlimited
        }))

        // Set up inputs / outputs
        let selectedModel = PassthroughSubject<FontModel, Never>()
        let inputs = FontSelectorViewModel.Inputs.mock(
            selectedModel: selectedModel.eraseToAnyPublisher()
        )
        let outputs = viewModel.bind(inputs)

        // Bind observers
        var cancellables: [AnyCancellable] = []
        cancellables.append(contentsOf: outputs.bindings)

        // Start steps
        let scheduler = TestScheduler(initialClock: .zero)
        let results = scheduler.start {
            let model = self.getModels(from: outputs, cancellables: &cancellables)[0]
            selectedModel.send(model)
            return fontObserver
        }

        // Verify the result
        XCTAssertEqual(results.recordedOutput, [
            (200, .subscription),
            (200, .input("1-font")),
        ])
    }

    /// Test if `model.menuFont` drives the value subject to push events
    func test_modelMenuFont() {
        // Set up dependencies
        let item = FontItem.mock(family: "1")
        let manager = FontManager.mock(fetchedItems: [item])
        let viewModel = FontSelectorViewModel.mock(manager: manager)

        // Set up inputs / outputs
        let inputs = FontSelectorViewModel.Inputs.mock()
        let outputs = viewModel.bind(inputs)

        // Bind observers
        let menuFontObserver = ReplaySubject<String?, Never>.createUnbounded()
        var cancellables: [AnyCancellable] = []
        cancellables.append(contentsOf: outputs.bindings)

        let model = getModels(from: outputs, cancellables: &cancellables)[0]
        cancellables.append(model.menu.sink { menuFontObserver.send($0) })

        // Start steps
        let scheduler = TestScheduler(initialClock: .zero)
        let results = scheduler.start {
            manager.pushMenu(for: item)
            return menuFontObserver
        }

        // Verify the result
        XCTAssertEqual(results.recordedOutput, [
            (200, .subscription),
            (200, .input(nil)),
            (200, .input("1-menuFont")),
        ])
    }

    /// Test if `model.state` drives the value subject to push events
    func test_modelFontState() {
        // Set up dependencies
        let item = FontItem.mock(family: "1")
        let manager = FontManager.mock(fetchedItems: [item])
        let viewModel = FontSelectorViewModel.mock(manager: manager)

        // Set up inputs / outputs
        let inputs = FontSelectorViewModel.Inputs.mock()
        let outputs = viewModel.bind(inputs)

        // Bind observers
        let downloadedObserver = ReplaySubject<Bool?, Never>.createUnbounded()
        var cancellables: [AnyCancellable] = []
        cancellables.append(contentsOf: outputs.bindings)

        let model = getModels(from: outputs, cancellables: &cancellables)[0]
        cancellables.append(model.state.map(\.?.isDownloaded).sink { downloadedObserver.send($0) })

        // Start steps
        let scheduler = TestScheduler(initialClock: .zero)
        let results = scheduler.start {
            manager.pushFontState(for: item)
            return downloadedObserver
        }

        // Verify the result
        XCTAssertEqual(results.recordedOutput, [
            (200, .subscription),
            (200, .input(nil)),
            (200, .input(true)),
        ])
    }

    // MARK: - Private

    private func getModels(from outputs: FontSelectorViewModel.Outputs, cancellables: inout [AnyCancellable]) -> [FontModel] {
        // Get models
        let modelsObserver = ReplaySubject<[FontModel], Never>.createUnbounded()
        cancellables.append(outputs.models.sink { modelsObserver.send($0) })
        let scheduler = TestScheduler(initialClock: .zero)
        let results = scheduler.start { modelsObserver }
        let signal = results.recordedOutput.suffix(1).first!.1
        guard case .input(let models) = signal else {
            fatalError()
        }
        return models
    }
}
