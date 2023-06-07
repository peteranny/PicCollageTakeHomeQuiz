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
        fetchedItems: [FontItem] = [],
        fetchedAtOnce: Bool = true
    ) -> MockFontManager {
        let manager = MockFontManager(fetchedItems: fetchedItems)
        if fetchedAtOnce {
            manager.fetchDone()
        }
        return manager
    }
}

struct MockFontManager: FontManaging {
    let fetchedItems: [FontItem]

    private let fetchedItemsDone = CurrentValueSubject<Bool, Never>(false)
    func fetchDone() {
        fetchedItemsDone.send(true)
    }
    func fetchItems() async throws -> [FontItem] {
        // Pend the request until done
        let trigger = fetchedItemsDone.filter { $0 }.first()
        return await trigger.map { _ in fetchedItems }.asFuture().value
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
