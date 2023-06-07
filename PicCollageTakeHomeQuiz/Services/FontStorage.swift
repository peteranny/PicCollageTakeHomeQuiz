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
    }

    // MARK: - Request

    static func request() -> Data? {
        storage.data(forKey: Key.request)
    }

    static func setRequest(_ data: Data) {
        storage.setValue(data, forKey: Key.request)
    }
}
