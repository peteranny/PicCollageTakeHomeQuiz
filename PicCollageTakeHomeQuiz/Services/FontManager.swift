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
}
