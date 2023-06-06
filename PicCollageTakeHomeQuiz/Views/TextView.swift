//
//  TextView.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/6.
//

import RxSwift
import UIKit

class TextView: UITextView {
    init(placeholder: String? = nil, placeholderColor: UIColor = .gray, textColor: UIColor = .black) {
        super.init(frame: .zero, textContainer: nil)

        installBindings(placeholder: placeholder, placeholderColor: placeholderColor, textColor: textColor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func installBindings(placeholder: String?, placeholderColor: UIColor, textColor: UIColor) {
        self.text = placeholder
        self.textColor = placeholderColor

        // Clear placeholder on focus
        let bindStartEditing = rx.didBeginEditing
            .filter { [weak self] in self?.textColor == placeholderColor }
            .subscribe(with: self, onNext: { base, _ in
                base.text = ""
                base.textColor = textColor
            })

        // Reset the placeholder on blur
        let bindEndEditing = rx.didEndEditing
            .filter { [weak self] in self?.text.isEmpty ?? false }
            .subscribe(with: self, onNext: { base, _ in
                base.text = placeholder
                base.textColor = placeholderColor
            })

        disposeBag.insert(
            bindStartEditing,
            bindEndEditing
        )
    }

    private let disposeBag = DisposeBag()
}
