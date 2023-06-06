//
//  FontManager.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/1.
//

import RxCocoa
import RxSwift

class FontManager {
    // MARK: Font items

    /// Fetch the font items
    func fetchItems() -> Single<[FontItem]> {
        // Invoked with the queue to prevent race condition on duplication
        stateQueue.async { self.fetchLatestItemsIfNeeded() }

        // Return the steram that does not emit the items until they are ready
        return itemsRelay
            .compactMap { $0 }
            .take(1)
            .asSingle()
    }

    /// Fetch the latest fonts from Google API.
    /// No-op when there has been already a request made.
    private func fetchLatestItemsIfNeeded() {
        guard fetchDisposable == nil else {
            // Early return if there is already a request made
            return
        }

        // Reference: https://developers.google.com/fonts/docs/developer_api
        let url = URL(string: "https://www.googleapis.com/webfonts/v1/webfonts?key=\(Constants.key)")!

        let response: Observable<Data>
        if let data = FontStorage.request(ttl: Constants.requestTTL) {
            response = .just(data)
        } else {
            let request = URLRequest(url: url)
            response = URLSession.shared.rx.data(request: request)
                .do(onNext: { FontStorage.setRequest($0) })
        }

        fetchDisposable = response
            .map { try JSONDecoder().decode(FontResponse.self, from: $0) }
            .map(\.items)
            .bind(to: itemsRelay)
    }

    private let stateQueue = DispatchQueue(label: "FontManager.stateQueue")
    private var fetchDisposable: Disposable?
    private let itemsRelay = BehaviorRelay<[FontItem]?>(value: nil)

    private enum Constants {
        static let key: String = {
            let encoded = Bundle.main.object(forInfoDictionaryKey: "GoogleFontKeyEncrypted") as! String
            let data = Data(base64Encoded: encoded)!
            let decoded = String(data: data, encoding: .utf8)!
            return decoded
        }()

        static let requestTTL = 60.0
    }

    // MARK: - Font menu

    /// Returns the menu driver for the given font item
    func menuDriver(for item: FontItem) -> Driver<String?> {
        // Return the menu associated with the family
        return menusRelay
            .asDriver()
            .map { $0[item.family] }
            .distinctUntilChanged()
            // Load the menu only on demand
            .do(onSubscribe: { [weak self] in
                // Invoked with the queue to prevent race condition on the stored menus
                self?.loadingQueue.async { self?.loadMenuIfNeeded(for: item) }
            })
    }

    /// Load the menu for the given font URL
    /// No-op when the menu has been loaded
    private func loadMenuIfNeeded(for item: FontItem) {
        let menu = stateQueue.sync {
            menusRelay.value[item.family]
        }

        guard menu == nil else {
            // Early return if there has been the font
            return
        }

        let data: Data
        if let cached = FontStorage.menu(for: item.family) {
            // Load the local cached menu data
            data = cached
        } else if let loaded = try? Data(contentsOf: item.menu) {
            // Download the menu data and cache it
            FontStorage.setMenu(loaded, for: item.family)
            data = loaded
        } else {
            return
        }

        let loaded = FontLoader.loadFont(for: data as NSData)

        // Set the menu
        stateQueue.async { [menusRelay] in
            var menus = menusRelay.value
            menus[item.family] = loaded
            menusRelay.accept(menus)
        }
    }

    private let loadingQueue = DispatchQueue(label: "FontManager.loadingQueue")
    private let menusRelay = BehaviorRelay<[String: String]>(value: [:])

    // MARK: - Font State

    /// Returns the font state driver for the given font item
    func fontStateDriver(for item: FontItem) -> Driver<FontState?> {
        statesRelay.asDriver()
            .map { $0[item.family] }
            .do(onSubscribe: { [weak self] in
                // Invoked with the queue to prevent race condition on the stored menus
                self?.loadingQueue.async { self?.loadFont(for: item, fetchIfNeeded: false) }
            })
    }

    /// Fetch the font for the given font item
    func fetchFont(for item: FontItem) {
        // Invoked with the queue to prevent race condition on duplication
        loadingQueue.async { self.loadFont(for: item, fetchIfNeeded: true) }
    }

    /// Load the font for the given font URL
    /// No-op when the font has been loaded
    private func loadFont(for item: FontItem, fetchIfNeeded: Bool) {
        guard fontState(for: item) == nil else {
            // Early return if there has been the font
            return
        }

        setFontState(.downloading, for: item)

        let data: Data
        if let cached = FontStorage.font(for: item.family) {
            // Load the local cached font data
            data = cached
        } else if fetchIfNeeded == false {
            // Do nothing if no need to fetch
            setFontState(nil, for: item)
            return
        } else if let url = item.files.values.first, let loaded = try? Data(contentsOf: url) {
            // Download the font data and cache it
            FontStorage.setFont(loaded, for: item.family)
            data = loaded
        } else {
            setFontState(.downloadFailed, for: item)
            return
        }

        guard let font = FontLoader.loadFont(for: data as NSData) else {
            setFontState(.downloadFailed, for: item)
            return
        }

        setFontState(.downloaded(name: font), for: item)
    }

    private func fontState(for item: FontItem) -> FontState? {
        stateQueue.sync {
            statesRelay.value[item.family]
        }
    }

    private func setFontState(_ fontState: FontState?, for item: FontItem) {
        stateQueue.async { [statesRelay] in
            var states = statesRelay.value
            states[item.family] = fontState
            statesRelay.accept(states)
        }
    }

    private let statesRelay = BehaviorRelay<[String: FontState]>(value: [:])
}
