//
//  FontSelectorViewModelTests.swift
//  PicCollageTakeHomeQuizTests
//
//  Created by Peteranny on 2023/6/7.
//

import RxBlocking
import RxCocoa
import RxSwift
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
        let categoriesObserver = ReplaySubject<[FontCategory]>.createUnbounded()
        let disposeBag = DisposeBag()
        disposeBag.insert(outputs.bindings)
        disposeBag.insert(outputs.categories.drive(categoriesObserver))

        // Verify the result
        categoriesObserver.onCompleted()
        let categories = try! categoriesObserver.toBlocking().toArray()
        XCTAssertEqual(categories, [
            [.all, .specific("a"), .specific("b")],
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
        let selectedCategory = PublishSubject<FontCategory>()
        let inputs = FontSelectorViewModel.Inputs.mock(
            selectedCategory: selectedCategory.asObservable()
        )
        let outputs = viewModel.bind(inputs)

        // Bind observers
        let selectedCategoryObserver = ReplaySubject<FontCategory>.createUnbounded()
        let disposeBag = DisposeBag()
        disposeBag.insert(outputs.bindings)
        disposeBag.insert(outputs.selectedCategory.drive(selectedCategoryObserver))

        // Steps
        selectedCategory.onNext(.specific("b"))
        selectedCategory.onNext(.specific("a"))
        selectedCategory.onNext(.all)

        // Verify the result
        selectedCategoryObserver.onCompleted()
        let selectedCategoryOut = try! selectedCategoryObserver.toBlocking().toArray()
        XCTAssertEqual(selectedCategoryOut, [
            .all,
            .specific("b"),
            .specific("a"),
            .all,
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
        let selectedCategory = PublishSubject<FontCategory>()
        let inputs = FontSelectorViewModel.Inputs.mock(
            selectedCategory: selectedCategory.asObservable()
        )
        let outputs = viewModel.bind(inputs)

        // Bind observers
        let familiesObserver = ReplaySubject<[String]>.createUnbounded()
        let disposeBag = DisposeBag()
        disposeBag.insert(outputs.bindings)
        disposeBag.insert(outputs.models.map({ $0.map(\.item.family) }).drive(familiesObserver))

        // Steps
        selectedCategory.onNext(.specific("a"))
        selectedCategory.onNext(.all)

        // Verify the result
        familiesObserver.onCompleted()
        let families = try! familiesObserver.toBlocking().toArray()
        XCTAssertEqual(families, [
            ["1", "2"],
            ["1"],
            ["1", "2"],
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
        let selectedModel = PublishSubject<FontModel>()
        let inputs = FontSelectorViewModel.Inputs.mock(
            selectedModel: selectedModel.asObservable()
        )
        let outputs = viewModel.bind(inputs)

        // Bind observers
        let selectedObserver = ReplaySubject<[Bool]>.createUnbounded()
        let disposeBag = DisposeBag()
        disposeBag.insert(outputs.bindings)
        disposeBag.insert(outputs.models.map({ $0.map(\.selected) }).drive(selectedObserver))

        // Steps
        let models = getModels(from: outputs, disposedBy: disposeBag)
        selectedModel.onNext(models[0])
        selectedModel.onNext(models[1])

        // Verify the result
        selectedObserver.onCompleted()
        let selected = try! selectedObserver.toBlocking().toArray()
        XCTAssertEqual(selected, [
            [false, false],
            [true, false],
            [false, true],
        ])
    }

    // MARK: - Private

    private func getModels(from outputs: FontSelectorViewModel.Outputs, disposedBy disposeBag: DisposeBag) -> [FontModel] {
        // Get models
        let modelsObserver = ReplaySubject<[FontModel]>.createUnbounded()
        disposeBag.insert(outputs.models.drive(modelsObserver))
        modelsObserver.onCompleted()
        let models = try! modelsObserver.toBlocking().last()!
        return models
    }
}
