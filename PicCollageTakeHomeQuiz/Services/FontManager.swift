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

    /// Fetch the fonts by initiating an API request to GoogleAPI
    func fetchItems() -> Single<[FontItem]> {
        // Reference: https://developers.google.com/fonts/docs/developer_api
        let url = URL(string: "https://www.googleapis.com/webfonts/v1/webfonts?key=\(Constants.key)")!

        let response: Observable<Data>
        if let data = FontStorage.request() {
            response = .just(data)
        } else {
            let request = URLRequest(url: url)
            response = URLSession.shared.rx.data(request: request)
                .do(onNext: { FontStorage.setRequest($0) })
        }

        return response
            .map { try JSONDecoder().decode(FontResponse.self, from: $0) }
            .map(\.items)
            .asSingle()
    }

    private enum Constants {
        static let key: String = {
            let encoded = Bundle.main.object(forInfoDictionaryKey: "GoogleFontKeyEncrypted") as! String
            let data = Data(base64Encoded: encoded)!
            let decoded = String(data: data, encoding: .utf8)!
            return decoded
        }()
    }
}
