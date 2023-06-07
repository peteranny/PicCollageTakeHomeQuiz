//
//  FontStorage.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/7.
//

import Foundation

enum FontStorage {
    private static let storage = UserDefaults.standard

    private enum Key {
        static let request = "request"
        static let requestDate = "request:date"
    }

    // MARK: - Request

    static func request(ttl: TimeInterval) -> Data? {
        guard let lastDate = storage.object(forKey: Key.requestDate) as? Date else {
            // Ignore cases without last date
            return nil
        }
        if lastDate.addingTimeInterval(ttl) < Date() {
            // Exceeds the expired date
            return nil
        }
        return storage.data(forKey: Key.request)
    }

    static func setRequest(_ data: Data) {
        storage.setValue(data, forKey: Key.request)
        storage.setValue(Date(), forKey: Key.requestDate)
    }
}