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
    func configure(title: String, font: AnyPublisher<String?, Never>, state: AnyPublisher<FontState?, Never>) {
        titleLabel.text = title

        // Respond to font changes
        let bindFont = font
            .map { [fontSize = titleLabel.font.pointSize] font in
                guard let font else {
                    return nil
                }
                return UIFont(name: font, size: fontSize)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.font, on: titleLabel)

        // Respond to the state
        let bindButtonHidden = state
            .map { $0.map { $0.isDownloaded || $0.isDownloading } ?? false }
            .receive(on: DispatchQueue.main)
            .assign(to: \.isHidden, on: downloadButton)

        let bindDownloadingHidden = state
            .map { $0?.isDownloading == true }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [spinner] in $0 ? spinner.startAnimating() : spinner.stopAnimating() })
            .map(!)
            .assign(to: \.isHidden, on: spinner)

        cancellables.append(contentsOf: [
            bindFont,
            bindButtonHidden,
            bindDownloadingHidden,
        ])
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
        ])

        // Install the download button
        contentView.addSubview(downloadButton)
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            downloadButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            downloadButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 4),
            downloadButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
        ])
        downloadButton.setImage(.init(systemName: "square.and.arrow.down"), for: .normal)
        downloadButton.tintColor = .black
        downloadButton.setContentHuggingPriority(.required, for: .horizontal)
        downloadButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        // Install the download button
        contentView.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerYAnchor.constraint(equalTo: downloadButton.centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo: downloadButton.centerXAnchor),
        ])
    }

    private let titleLabel = UILabel()
    private let downloadButton = UIButton()
    private let spinner = UIActivityIndicatorView()
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
        cell.configure(title: model.item.family, font: model.menu, state: model.state)
    }
}
