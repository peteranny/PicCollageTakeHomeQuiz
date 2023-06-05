//
//  FontModel.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/5.
//

import Combine
import UIKit

struct FontModel: Equatable, Hashable {
    let item: FontItem
    let menu: AnyPublisher<String?, Never>

    func hash(into hasher: inout Hasher) {
        hasher.combine(item)
    }

    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.item == rhs.item
    }
}
