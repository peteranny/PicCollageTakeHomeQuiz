//
//  SegmentationControl.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/2.
//

import UIKit

/// The control that allows the user to switch among segments.
/// Horizontal scrollbar appears if the segments are out of the bounds so user can scroll to reveal them.
class SegmentationControl: UIScrollView {
    init() {
        super.init(frame: .zero)

        installSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func installSubviews() {
        showsHorizontalScrollIndicator = false

        // Install the horizontal stack view
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: heightAnchor),
        ])
        stackView.spacing = 10
        stackView.clipsToBounds = false

        // Install items by adding one label per segment
        // TODO: Replaced with configurable segments
        for title in ["All", "中文"] {
            let label = UILabel()
            label.text = title
            label.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(label)
        }
    }

    private let stackView = UIStackView()
}
