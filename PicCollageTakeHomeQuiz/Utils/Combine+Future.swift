//
//  Combine+Future.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peter Shih on 2023/8/8.
//

import Combine

extension Future where Failure == Error {
    convenience init(_ asyncFunc: @escaping () async throws -> Output) {
        self.init { promise in
            Task {
                do {
                    let result = try await asyncFunc()
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}
