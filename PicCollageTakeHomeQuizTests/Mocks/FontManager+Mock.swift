//
//  MockFontManager.swift
//  PicCollageTakeHomeQuizTests
//
//  Created by Peteranny on 2023/6/7.
//

import Combine
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

    func fetchItems() async throws -> [FontItem] {
        fetchedItems
    }

    func menuDriver(for item: FontItem) -> AnyPublisher<String?, Never> {
        Just(nil).eraseToAnyPublisher()
    }

    func fontStateDriver(for item: FontItem) -> AnyPublisher<FontState?, Never> {
        Just(nil).eraseToAnyPublisher()
    }

    func fetchFont(for item: FontItem) async throws -> String {
        item.family + "-font"
    }
}
