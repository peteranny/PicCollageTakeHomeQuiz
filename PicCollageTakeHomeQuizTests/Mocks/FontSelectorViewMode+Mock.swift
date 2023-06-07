//
//  FontSelectorViewMode+Mock.swift
//  PicCollageTakeHomeQuizTests
//
//  Created by Peteranny on 2023/6/7.
//

import Combine
@testable import PicCollageTakeHomeQuiz

extension FontSelectorViewModel {
    /// Create a instance with partial inputs as well as the rest being mocked
    static func mock(manager: MockFontManager) -> FontSelectorViewModel {
        .init(manager: manager, fontObserver: AnySubscriber())
    }
}

extension FontSelectorViewModel.Inputs {
    /// Create a instance with partial inputs as well as the rest being mocked
    static func mock(
        selectedCategory: AnyPublisher<FontCategory, Never> = Empty().eraseToAnyPublisher(),
        selectedModel: AnyPublisher<FontModel, Never> = Empty().eraseToAnyPublisher()
    ) -> Self {
        .init(
            selectedCategory: selectedCategory,
            selectedModel: selectedModel
        )
    }
}
