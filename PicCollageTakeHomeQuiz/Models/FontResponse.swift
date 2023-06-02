//
//  FontResponse.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/5.
//

/// Reference: https://developers.google.com/fonts/docs/developer_api
struct FontResponse: Decodable {
    let items: [FontItem]
    let kind: String
}
