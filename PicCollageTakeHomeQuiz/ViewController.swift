//
//  ViewController.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/6.
//

import RxSwift
import UIKit

class ViewController: UIViewController {
    init(manager: FontManager) {
        self.manager = manager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        installSubviews()
        installBindings()
    }

    // MARK: - Private

    private func installSubviews() {
        view.backgroundColor = .white

        // Install the text view
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        let textViewButtonConstraint = textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        textViewButtonConstraint.priority = .defaultHigh // Anchor to bottom only when there is no font selector
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textViewButtonConstraint,
        ])
        textView.font = .systemFont(ofSize: 20)

        // Install the font button
        view.addSubview(fontButton)
        fontButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fontButton.topAnchor.constraint(equalTo: textView.topAnchor),
            fontButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor),
            fontButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fontButton.widthAnchor.constraint(equalToConstant: 30),
            fontButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }

    private func installBindings() {
        // Dismiss the keyboard on tapping the font button
        let bindKeyboardDismissal = fontButton.rx.tap
            .subscribe(with: textView, onNext: { base, _ in
                base.resignFirstResponder()
            })

        // Toggle the font selector on tapping the font button
        let bindFontSelectorInstallation = fontButton.rx.tap
            .subscribe(with: self, onNext: { base, _ in
                base.fontSelector == nil ? base.installFontSelector() : base.uninstallFontSelector()
            })

        // Dismiss the font selector on tapping the text view
        let bindFontSelectorDismissal = textView.rx.didBeginEditing
            .subscribe(with: self, onNext: { base, _ in
                base.uninstallFontSelector()
            })

        disposeBag.insert(
            bindKeyboardDismissal,
            bindFontSelectorInstallation,
            bindFontSelectorDismissal
        )
    }

    private func installFontSelector() {
        guard fontSelector == nil else {
            return
        }

        let viewController = FontSelectorViewController(viewModel: fontSelectorViewModel)
        viewController.view.layer.shadowColor = UIColor.gray.cgColor
        viewController.view.layer.shadowOpacity = 1
        viewController.view.layer.shadowOffset = .zero
        viewController.view.layer.shadowRadius = 10
        viewController.view.layer.cornerRadius = 10

        // Install the view controller
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: textView.bottomAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewController.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8),
        ])
        viewController.didMove(toParent: self)

        // Save the reference
        fontSelector = viewController

        // Animation
        viewController.view.transform = .identity.translatedBy(x: 0, y: UIScreen.main.bounds.height)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            viewController.view.transform = .identity
        })
    }

    private func uninstallFontSelector() {
        guard let viewController = fontSelector else {
            return
        }

        // Animation
        viewController.view.transform = .identity
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, animations: {
            viewController.view.transform = .identity.translatedBy(x: 1, y: UIScreen.main.bounds.height)
        }, completion: { _ in
            // Uninstall the view controller
            viewController.willMove(toParent: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()

            // Unset the reference
            self.fontSelector = nil
        })
    }

    private lazy var fontSelectorViewModel: FontSelectorViewModel = {
        let fontBinder: Binder<String> = Binder(textView) { base, fontName in
            let fontSize = base.font?.pointSize ?? 0
            base.font = UIFont(name: fontName, size: fontSize)
        }

        return FontSelectorViewModel(manager: manager, fontObserver: fontBinder.asObserver())
    }()

    private let manager: FontManager
    private let textView = TextView(placeholder: "Enter some text here")
    private let fontButton = FontButton()
    private var fontSelector: UIViewController?
    private let disposeBag = DisposeBag()
}
