//
//  MockFontManager.swift
//  PicCollageTakeHomeQuizTests
//
//  Created by Peteranny on 2023/6/7.
//

import RxCocoa
import RxSwift
@testable import PicCollageTakeHomeQuiz

extension FontManager {
    /// Create a mock instance with partial inputs as well as the rest being mocked
    static func mock(
        fetchedItems: [FontItem] = []
    ) -> MockFontManager {
        .init(fetchedItems: fetchedItems)
    }
}

struct MockFontManager: FontManaging {
    let fetchedItems: [FontItem]

    func fetchItems() -> Single<[FontItem]> {
        .just(fetchedItems)
    }

    func menuDriver(for item: FontItem) -> Driver<String?> {
        .just(nil)
    }

    func fontStateDriver(for item: FontItem) -> Driver<FontState?> {
        .just(nil)
    }

    func fetchFont(for item: FontItem) -> Single<String> {
        .just("")
    }
}
