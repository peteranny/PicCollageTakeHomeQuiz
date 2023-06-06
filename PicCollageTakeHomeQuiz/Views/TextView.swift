//
//  TextView.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/6.
//

import Combine
import CombineCocoa
import UIKit

class TextView: UITextField {
    init(placeholder: String? = nil, placeholderColor: UIColor = .gray, textColor: UIColor = .black) {
        super.init(frame: .zero)

        installBindings(placeholder: placeholder, placeholderColor: placeholderColor, textColor: textColor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func installBindings(placeholder: String?, placeholderColor: UIColor, textColor: UIColor) {
        self.text = placeholder
        self.textColor = placeholderColor
        self.contentVerticalAlignment = .top

        // Clear placeholder on focus
        let bindStartEditing = controlEventPublisher(for: .editingDidBegin)
            .filter { [weak self] in self?.textColor == placeholderColor }
            .sink { [weak base = self] _ in
                base?.text = ""
                base?.textColor = textColor
            }

        // Reset the placeholder on blur
        let bindEndEditing = controlEventPublisher(for: .editingDidEnd)
            .filter { [weak self] in self?.text?.isEmpty ?? false }
            .sink { [weak base = self] _ in
                base?.text = placeholder
                base?.textColor = placeholderColor
            }

        cancellables.append(contentsOf: [
            bindStartEditing,
            bindEndEditing,
        ])
    }

    private var cancellables: [AnyCancellable] = []
}
