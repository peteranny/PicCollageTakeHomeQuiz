//
//  FontSelectorViewMode+Mock.swift
//  PicCollageTakeHomeQuizTests
//
//  Created by Peteranny on 2023/6/7.
//

import RxCocoa
import RxSwift
@testable import PicCollageTakeHomeQuiz

extension FontSelectorViewModel {
    /// Create a instance with partial inputs as well as the rest being mocked
    static func mock(manager: MockFontManager, fontObserver: AnyObserver<String> = AnyObserver { _ in }) -> FontSelectorViewModel {
        .init(manager: manager, fontObserver: fontObserver)
    }
}

extension FontSelectorViewModel.Inputs {
    /// Create a instance with partial inputs as well as the rest being mocked
    static func mock(
        selectedCategory: Observable<FontCategory> = .never(),
        selectedModel: Observable<FontModel> = .never()
    ) -> Self {
        .init(
            selectedCategory: selectedCategory,
            selectedModel: selectedModel
        )
    }
}
