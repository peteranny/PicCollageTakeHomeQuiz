//
//  MockFontItem.swift
//  PicCollageTakeHomeQuizTests
//
//  Created by Peteranny on 2023/6/7.
//

import Foundation
@testable import PicCollageTakeHomeQuiz

extension FontItem {

    /// Create a instance with partial inputs as well as the rest being mocked
    static func mock(family: String = "", category: String = "") -> Self {
        .init(
            kind: "",
            family: family,
            subsets: [],
            menu: URL(string: "file://")!,
            variants: [],
            version: "",
            lastModified: "",
            files: [:],
            category: category
        )
    }

}
