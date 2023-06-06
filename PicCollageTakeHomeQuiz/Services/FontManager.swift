//
//  FontManager.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/1.
//

import Combine
import Foundation

class FontManager {
    // MARK: Font items

    /// Fetch the font items
    func fetchItems() async throws -> [FontItem] {
        // Invoked with the queue to prevent race condition on duplication
        stateQueue.async { self.fetchLatestItemsIfNeeded() }

        // Return the steram that does not emit the items until they are ready
        return try await itemsRelay
            .compactMap { $0 }
            .first()
            .asFuture()
            .value
    }

    /// Fetch the latest fonts from Google API.
    /// No-op when there has been already a request made.
    private func fetchLatestItemsIfNeeded() {
        if hasFetched {
            // Early return if there is already a request made
            return
        }
        hasFetched = true

        // Reference: https://developers.google.com/fonts/docs/developer_api
        let url = URL(string: "https://www.googleapis.com/webfonts/v1/webfonts?key=\(Constants.key)")!

        Task {
            do {
                let data: Data
                if let cached = FontStorage.request(ttl: Constants.requestTTL) {
                    data = cached
                } else {
                    let request = URLRequest(url: url)
                    let (fetched, _) = try await URLSession.shared.data(for: request)
                    FontStorage.setRequest(fetched)
                    data = fetched
                }

                let response = try JSONDecoder().decode(FontResponse.self, from: data)
                itemsRelay.send(response.items)
                itemsRelay.send(completion: .finished)
            } catch {
                itemsRelay.send(completion: .failure(error))
            }
        }
    }

    private let stateQueue = DispatchQueue(label: "FontManager.stateQueue")
    private var hasFetched = false
    private let itemsRelay = CurrentValueSubject<[FontItem]?, Error>(nil)

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
    func menuDriver(for item: FontItem) -> AnyPublisher<String?, Never> {
        // Return the menu associated with the family
        return menusRelay
            .map { $0[item.family] }
            .removeDuplicates()
            // Load the menu only on demand
            .handleEvents(receiveSubscription: { [weak self] _ in
                // Invoked with the queue to prevent race condition on the stored menus
                self?.loadingQueue.async { self?.loadMenuIfNeeded(for: item) }
            })
            .eraseToAnyPublisher()
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
            menusRelay.send(menus)
        }
    }

    private let loadingQueue = DispatchQueue(label: "FontManager.loadingQueue")
    private let menusRelay = CurrentValueSubject<[String: String], Never>([:])

    // MARK: - Font State

    /// Returns the font state driver for the given font item
    func fontStateDriver(for item: FontItem) -> AnyPublisher<FontState?, Never> {
        statesRelay
            .map { $0[item.family] }
            .handleEvents(receiveSubscription: { [weak self] _ in
                // Invoked with the queue to prevent race condition on the stored menus
                self?.loadingQueue.async { self?.loadFont(for: item, fetchIfNeeded: false) }
            })
            .eraseToAnyPublisher()
    }

    /// Fetch the font for the given font item
    func fetchFont(for item: FontItem) async throws -> String {
        // Invoked with the queue to prevent race condition on duplication
        loadingQueue.async { self.loadFont(for: item, fetchIfNeeded: true) }

        // Return the steram that does not emit the font until it is ready
        return try await statesRelay
            .map { $0[item.family] }
            .tryCompactMap { state -> String? in
                switch state {
                case .downloaded(let name):
                    return name
                case .downloadFailed:
                    throw NSError(domain: "FontManager", code: 0)
                case .downloading, .none:
                    return nil
                }
            }
            .first()
            .asFuture()
            .value
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
            statesRelay.send(states)
        }
    }

    private let statesRelay = CurrentValueSubject<[String: FontState], Never>([:])
}
