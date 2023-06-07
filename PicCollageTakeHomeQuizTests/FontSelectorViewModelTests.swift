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
}
