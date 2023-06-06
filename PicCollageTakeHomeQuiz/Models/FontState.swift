//
//  FontState.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/7.
//

import UIKit

enum FontState {
    case downloading
    case downloaded(name: String)
    case downloadFailed

    var isDownloading: Bool {
        if case .downloading = self {
            return true
        } else {
            return false
        }
    }

    var isDownloaded: Bool {
        if case .downloaded = self {
            return true
        } else {
            return false
        }
    }
}
