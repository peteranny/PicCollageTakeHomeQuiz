//
//  ViewController.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/1.
//

import RxDataSources
import RxSwift
import UIKit

class FontSelectorViewController: UIViewController {
    init(viewModel: FontSelectorViewModel) {
        self.viewModel = viewModel
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

        // Install the segmentation control on the top
        view.addSubview(segmentationControl)
        segmentationControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentationControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            segmentationControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            segmentationControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
        ])

        // Install the separator below the control
        view.addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            separator.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            separator.topAnchor.constraint(equalTo: segmentationControl.bottomAnchor, constant: 10),
        ])

        // Install the collection view below the separator
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            collectionView.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        collectionView.backgroundView = spinner
        spinner.hidesWhenStopped = true
    }

    private func installBindings() {
        // The inputs to the view model
        let selectedCategory = segmentationControl.rx.selectedIdentifier
            .compactMap({ $0 })
            .map({ FontCategory(rawValue: $0) })

        let selectedModel = collectionView.rx.modelSelected

        let inputs = FontSelectorViewModel.Inputs(
            selectedCategory: selectedCategory,
            selectedModel: selectedModel
        )

        // Binds the inputs and gets the outputs
        let outputs = viewModel.bind(inputs)

        // Binds the outputs
        let bindLoading = outputs.isLoading
            .drive(with: spinner, onNext: { base, isLoading in
                isLoading ? base.startAnimating() : base.stopAnimating()
            })

        let bindModels = outputs.models.drive(collectionView.rx.models)

        let bindSelectedCategory = outputs.selectedCategory
            .map({ $0.title })
            .drive(segmentationControl.rx.selectedIdentifier)

        let bindScrollToTop = outputs.selectedCategory.map { _ in .zero }.drive(collectionView.rx.contentOffset)

        let bindCategories = outputs.categories
            .map { $0.map { SegmentationControl.Item(title: $0.title, identifier: $0.title) } } // Each category maps to a segmentation item
            .drive(segmentationControl.rx.items)

        disposeBag.insert(
            bindLoading,
            bindModels,
            bindSelectedCategory,
            bindScrollToTop,
            bindCategories,
            outputs.bindings
        )
    }

    private let segmentationControl = SegmentationControl()
    private let separator = SolidLineView(axis: .horizontal, thickness: 0.5, backgroundColor: .black)
    private let collectionView = FontCollectionView()
    private let spinner = UIActivityIndicatorView()
    private let viewModel: FontSelectorViewModel
    private let disposeBag = DisposeBag()
}

