//
//  SolidLineView.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/2.
//

import UIKit

class SolidLineView: UIView {
    /// - Parameters:
    ///   - axis: Determines if the line is vertical or horizontal.
    ///   - thickness: The width for a vertical line, or the height for horizontal.
    ///   - backgroundColor: The color of the line.
    init(axis: NSLayoutConstraint.Axis, thickness: CGFloat, backgroundColor: UIColor) {
        super.init(frame: .zero)

        self.backgroundColor = backgroundColor

        switch axis {
        case .vertical:
            widthAnchor.constraint(equalToConstant: thickness).isActive = true

        case .horizontal:
            heightAnchor.constraint(equalToConstant: thickness).isActive = true

        @unknown default:
            break
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
