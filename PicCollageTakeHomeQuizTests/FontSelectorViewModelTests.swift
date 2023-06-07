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
}
