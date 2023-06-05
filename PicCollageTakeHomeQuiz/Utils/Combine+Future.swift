//
//  Combine+Future.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peter Shih on 2023/8/8.
//

import Combine

extension Publisher {
    func asFuture() -> Future<Output, Failure> {
        Future { promise in
            var cancellable: AnyCancellable?
            cancellable = sink { completion in
                cancellable?.cancel()
                cancellable = nil
                switch completion {
                case .failure(let error):
                    promise(.failure(error))

                case .finished:
                    break
                }
            } receiveValue: { value in
                cancellable?.cancel()
                cancellable = nil
                promise(.success(value))
            }
        }
    }
}

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
