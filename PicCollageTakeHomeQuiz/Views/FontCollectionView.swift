//
//  FontCollectionView.swift
//  PicCollageTakeHomeQuiz
//
//  Created by Peteranny on 2023/6/2.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

// MARK: - Section / Item for RxDataSources

struct FontItem {
    let title: String
}

struct FontSection {
    let items: [FontItem]
}

extension FontSection: SectionModelType {
    init(original: FontSection, items: [FontItem]) {
        self.init(items: items)
    }
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
        let rxDataSource = RxCollectionViewSectionedReloadDataSource<FontSection> { _, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FontCollectionViewCell", for: indexPath) as! FontCollectionViewCell
            cell.configure(title: item.title)
            return cell
        }

        // Hard-coded models
        // TODO: Replaced with real models
        let sections: [FontSection] = [
            .init(items: [
                .init(title: "HAUNTED"),
                .init(title: "Helvetica"),
            ]),
        ]

        // Bind the models to the data source
        Observable.just(sections)
            .bind(to: rx.items(dataSource: rxDataSource))
            .disposed(by: disposeBag)
    }

    private let disposeBag = DisposeBag()
}
