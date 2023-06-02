//
//  FontCollectionView.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/2.
//

import Combine
import CombineDataSources
import UIKit

// MARK: - Section / Item for RxDataSources

struct FontItem: Hashable {
    let title: String
}

// MARK: - Cell

class FontCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)

        installSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Configure the cell with the provided font context
    /// - Parameter title: The font title
    func configure(title: String) {
        titleLabel.text = title
    }

    // MARK: - Private

    private func installSubviews() {
        contentView.backgroundColor = .lightGray

        // Install the title label
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        ])
    }

    private let titleLabel = UILabel()
}

// MARK: - Collection view

/// The collection view that displays a list of font items.
class FontCollectionView: UICollectionView {
    init() {
        let layout = UICollectionViewFlowLayout()
        super.init(frame: .zero, collectionViewLayout: layout)

        // Configure the layout such that every row contains two cells
        layout.itemSize = .init(width: (UIScreen.main.bounds.width - 30) / 2, height: 60)

        installCells()
        installBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func installCells() {
        register(FontCollectionViewCell.self, forCellWithReuseIdentifier: "FontCollectionViewCell")
    }

    private func installBindings() {
        // The data source that consumes an item to render the cell
        let subscriber: AnySubscriber<[FontItem], Never> = itemsSubscriber(cellIdentifier: "FontCollectionViewCell", cellType: FontCollectionViewCell.self) { cell, indexPath, item in
            cell.configure(title: item.title)
        }

        // Hard-coded models
        // TODO: Replaced with real models
        let items: [FontItem] = [
            .init(title: "HAUNTED"),
            .init(title: "Helvetica"),
        ]

        // Bind the models to the data source
        Just<[FontItem]>(items)
            .bind(subscriber: subscriber)
            .store(in: &cancellables)
    }

    private var cancellables: [AnyCancellable] = []
}
