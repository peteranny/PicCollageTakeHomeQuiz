//
//  FontButton.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/6.
//

import UIKit

class FontButton: UIButton {
    init() {
        super.init(frame: .zero)

        setImage(.init(systemName: "a"), for: .normal)
        tintColor = .white
        backgroundColor = .lightGray
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
