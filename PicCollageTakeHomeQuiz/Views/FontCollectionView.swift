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
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func installCells() {
        register(FontCollectionViewCell.self, forCellWithReuseIdentifier: "FontCollectionViewCell")
    }

    // The data source that consumes an item to render the cell
    fileprivate let rxDataSource = RxCollectionViewSectionedReloadDataSource<FontSection> { _, collectionView, indexPath, item in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FontCollectionViewCell", for: indexPath) as! FontCollectionViewCell
        cell.configure(title: item.title)
        return cell
    }
}

extension Reactive where Base: FontCollectionView {
    // Returns the binder that binds items to the data sources
    var items: (Observable<[FontItem]>) -> Disposable {

        // Get the binder that binds the sections to the data source
        let binder: (Observable<[FontSection]>) -> Disposable = items(dataSource: base.rxDataSource)

        // Returns the closure with the items as the inputs
        return { items in

            // Maps the items to the sections
            let sections = items.map { [FontSection(items: $0)] }

            // Binds the sections to the data source
            return binder(sections)

        }
    }
}
