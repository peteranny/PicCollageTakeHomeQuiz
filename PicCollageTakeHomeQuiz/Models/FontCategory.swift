//
//  FontCategory.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/6.
//

enum FontCategory: Equatable {
    case all
    case specific(String)

    init(rawValue: String) {
        switch rawValue {
        case Constants.all:
            self = .all
        default:
            self = .specific(rawValue)
        }
    }

    var title: String {
        switch self {
        case .all:
            return Constants.all
        case .specific(let title):
            return title
        }
    }

    enum Constants {
        static let all = "All"
    }
}
