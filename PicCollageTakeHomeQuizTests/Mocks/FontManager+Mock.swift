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

    private let menuRelay = CurrentValueSubject<String?, Never>(nil)
    func pushMenu(for item: FontItem) {
        menuRelay.send(item.family + "-menuFont")
    }
    func menuDriver(for item: FontItem) -> AnyPublisher<String?, Never> {
        menuRelay
            .filter { $0?.starts(with: item.family) ?? true } // Nil applies to all items
            .eraseToAnyPublisher()
    }

    private let fontStateRelay = CurrentValueSubject<String?, Never>(nil)
    func pushFontState(for item: FontItem) {
        fontStateRelay.send(item.family)
    }
    func fontStateDriver(for item: FontItem) -> AnyPublisher<FontState?, Never> {
        fontStateRelay
            .filter { $0?.starts(with: item.family) ?? true } // Nil applies to all items
            .map { $0 != nil ? .downloaded(name: item.family + "-downloaded") : nil } // Maps non-nil to .downloaded
            .eraseToAnyPublisher()
    }

    func fetchFont(for item: FontItem) async throws -> String {
        item.family + "-font"
    }
}
