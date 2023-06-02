//
//  SegmentationControl.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/2.
//

import RxCocoa
import RxSwift
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
            .asDriver()
            .drive(with: self, onNext: { base, identifier in
                base.setSelectedIdentifier(identifier)
            })
            .disposed(by: disposeBag)

        userDrivenSelectedIdentifierRelay
            .bind(to: selectedIdentifierRelay)
            .disposed(by: disposeBag)
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
            buttonDisposeBag.insert(
                button.rx.tap.map { item.identifier }.bind(to: userDrivenSelectedIdentifierRelay)
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

    fileprivate var items: [Item] = [] {
        didSet { setItems(items) }
    }

    private let stackView = UIStackView()
    fileprivate let userDrivenSelectedIdentifierRelay = PublishRelay<String?>()
    fileprivate let selectedIdentifierRelay = BehaviorRelay<String?>(value: nil)
    private let disposeBag = DisposeBag()
    private var buttonDisposeBag = DisposeBag()
}

extension Reactive where Base: SegmentationControl {
    var items: Binder<[Base.Item]> {
        Binder(base) { base, items in
            base.items = items
        }
    }

    var selectedIdentifier: ControlProperty<String?> {
        let values = base.userDrivenSelectedIdentifierRelay
        let valueSink = Binder(base) { base, identifier in base.selectedIdentifierRelay.accept(identifier) }
        return ControlProperty(values: values, valueSink: valueSink)
    }
}
