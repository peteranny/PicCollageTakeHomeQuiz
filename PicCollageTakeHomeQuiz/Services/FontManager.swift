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

    /// Fetch the fonts by initiating an API request to GoogleAPI
    func fetchItems() async throws -> [FontItem] {
        // Reference: https://developers.google.com/fonts/docs/developer_api
        let url = URL(string: "https://www.googleapis.com/webfonts/v1/webfonts?key=\(Constants.key)")!

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
        return response.items
    }

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
