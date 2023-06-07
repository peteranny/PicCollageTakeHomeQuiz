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

    private let fetchedItemsDone = BehaviorRelay<Bool>(value: false)
    func fetchDone() {
        fetchedItemsDone.accept(true)
    }
    func fetchItems() -> Single<[FontItem]> {
        // Pend the request until done
        let trigger = fetchedItemsDone.filter { $0 }.take(1)
        return trigger.map { _ in fetchedItems }.asSingle()
    }

    private let menuRelay = BehaviorRelay<String?>(value: nil)
    func pushMenu(for item: FontItem) {
        menuRelay.accept(item.family + "-menuFont")
    }
    func menuDriver(for item: FontItem) -> Driver<String?> {
        menuRelay.asDriver()
            .filter { $0?.starts(with: item.family) ?? true } // Nil applies to all items
    }

    private let fontStateRelay = BehaviorRelay<String?>(value: nil)
    func pushFontState(for item: FontItem) {
        fontStateRelay.accept(item.family)
    }
    func fontStateDriver(for item: FontItem) -> Driver<FontState?> {
        fontStateRelay.asDriver()
            .filter { $0?.starts(with: item.family) ?? true } // Nil applies to all items
            .map { $0 != nil ? .downloaded(name: item.family + "-downloaded") : nil } // Maps non-nil to .downloaded
    }

    func fetchFont(for item: FontItem) -> Single<String> {
        .just(item.family + "-font")
    }
}
