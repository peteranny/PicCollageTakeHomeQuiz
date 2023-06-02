//
//  SegmentationControl.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/2.
//

import Combine
import CombineCocoa
import UIKit

/// The control that allows the user to switch among segments.
/// Horizontal scrollbar appears if the segments are out of the bounds so user can scroll to reveal them.
class SegmentationControl: UIScrollView {
    struct Item {
        let title: String
        let identifier: String
    }

    init() {
        super.init(frame: .zero)

        installSubviews()
        installBindings()
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

    private func installBindings() {
        selectedIdentifierRelay
            .sink(receiveValue: { [weak self] in
                self?.setSelectedIdentifier($0)
            })
            .store(in: &cancellables)

        userDrivenSelectedIdentifierRelay
            .sink(receiveValue: { [selectedIdentifierRelay] in
                selectedIdentifierRelay.send($0)
            })
            .store(in: &cancellables)
    }

    private func setItems(_ items: [Item]) {
        // Remove previous segments
        for subview in stackView.subviews {
            subview.removeFromSuperview()
        }

        // Install items by adding one label per segment
        for item in items {
            let button = UIButton()
            button.setTitle(item.title, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.setTitleColor(.systemGreen, for: .selected)
            button.translatesAutoresizingMaskIntoConstraints = false
            buttonCancellables.append(
                button.tapPublisher.map { item.identifier }.sink(receiveValue: { [userDrivenSelectedIdentifierRelay] in userDrivenSelectedIdentifierRelay.send($0) })
            )
            stackView.addArrangedSubview(button)
        }

        setSelectedIdentifier(selectedIdentifierRelay.value)
    }

    private func setSelectedIdentifier(_ identifier: String?) {
        for (index, subview) in stackView.subviews.enumerated() {
            (subview as? UIButton)?.isSelected = items[index].identifier == identifier
        }
    }

    var items: [Item] = [] {
        didSet { setItems(items) }
    }

    private let stackView = UIStackView()
    private let userDrivenSelectedIdentifierRelay = PassthroughSubject<String?, Never>()
    private let selectedIdentifierRelay = CurrentValueSubject<String?, Never>(nil)
    private var cancellables: [AnyCancellable] = []
    private var buttonCancellables: [AnyCancellable] = []

    var selectedIdentifierPublisher: AnyPublisher<String?, Never> {
        userDrivenSelectedIdentifierRelay.eraseToAnyPublisher()
    }

    var selectedIdentifier: String? {
        get { selectedIdentifierRelay.value }
        set { selectedIdentifierRelay.send(newValue) }
    }
}
