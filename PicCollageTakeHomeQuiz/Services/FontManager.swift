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
}
