//
//  SegmentationControl.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/2.
//

import RxSwift
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
    }

    private func setItems(_ items: [String]) {
        // Remove previous segments
        for subview in stackView.subviews {
            subview.removeFromSuperview()
        }

        // Install items by adding one label per segment
        for item in items {
            let label = UILabel()
            label.text = item
            label.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(label)
        }
    }

    fileprivate var items: [String] = [] {
        didSet { setItems(items) }
    }

    private let stackView = UIStackView()
}

extension Reactive where Base: SegmentationControl {
    var items: Binder<[String]> {
        Binder(base) { base, items in
            base.items = items
        }
    }
}
