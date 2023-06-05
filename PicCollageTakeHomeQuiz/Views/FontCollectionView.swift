//
//  FontCollectionView.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/2.
//

import Combine
import CombineDataSources
import UIKit

// MARK: - Section for RxDataSources

// MARK: - Cell

class FontCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)

        installSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        cancellables = []
    }

    /// Configure the cell with the provided font context
    /// - Parameter title: The font title
    func configure(title: String, font: AnyPublisher<String?, Never>) {
        titleLabel.text = title

        // Respond to font changes
        font
            .map { [fontSize = titleLabel.font.pointSize] font in
                guard let font else {
                    return nil
                }
                return UIFont(name: font, size: fontSize)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.font, on: titleLabel)
            .store(in: &cancellables)
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
    private var cancellables: [AnyCancellable] = []
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
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func installCells() {
        register(FontCollectionViewCell.self, forCellWithReuseIdentifier: "FontCollectionViewCell")
    }

    // The data source that consumes an item to render the cell
    private(set) lazy var subscriber: AnySubscriber<[FontModel], Never> = itemsSubscriber(cellIdentifier: "FontCollectionViewCell", cellType: FontCollectionViewCell.self) { cell, indexPath, model in
        cell.configure(title: model.item.family, font: model.menu)
    }

}
