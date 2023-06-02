//
//  ViewController.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/1.
//

import UIKit

class FontSelectorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        installSubviews()
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
    }

    private let segmentationControl = SegmentationControl()
    private let separator = SolidLineView(axis: .horizontal, thickness: 0.5, backgroundColor: .black)
    private let collectionView = FontCollectionView()
}

