//
//  FontCategory.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/6.
//

enum FontCategory {
    case all
    case specific(String)

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
