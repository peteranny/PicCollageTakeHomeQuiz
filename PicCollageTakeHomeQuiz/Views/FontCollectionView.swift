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

// MARK: - Section for RxDataSources

struct FontSection {
    let models: [FontModel]
}

extension FontSection: SectionModelType {
    init(original: FontSection, items models: [FontModel]) {
        self.init(models: models)
    }

    var items: [FontModel] {
        models
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

    override func prepareForReuse() {
        super.prepareForReuse()

        disposeBag = DisposeBag()
    }

    /// Configure the cell with the provided font context
    /// - Parameter title: The font title
    func configure(title: String, font: Driver<String?>, state: Driver<FontState?>, selected: Bool) {
        titleLabel.text = title
        contentView.layer.borderWidth = 5
        contentView.layer.borderColor = selected ? UIColor.green.cgColor : UIColor.clear.cgColor

        // Respond to font changes
        let bindFont = font
            .map { [fontSize = titleLabel.font.pointSize] font in
                guard let font else {
                    return nil
                }
                return UIFont(name: font, size: fontSize)
            }
            .drive(titleLabel.rx.font)

        // Respond to the state
        let bindButtonHidden = state
            .map { $0.map { $0.isDownloaded || $0.isDownloading } ?? false }
            .drive(downloadButton.rx.isHidden)

        let bindDownloadingHidden = state
            .map { $0?.isDownloading == true }
            .do(onNext: { [spinner] in $0 ? spinner.startAnimating() : spinner.stopAnimating() })
            .drive(spinner.rx.isHidden.mapObserver(!))

        disposeBag.insert(
            bindFont,
            bindButtonHidden,
            bindDownloadingHidden
        )
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
    private var disposeBag = DisposeBag()
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
    fileprivate let rxDataSource = RxCollectionViewSectionedReloadDataSource<FontSection> { _, collectionView, indexPath, model in
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FontCollectionViewCell", for: indexPath) as! FontCollectionViewCell
        cell.configure(title: model.item.family, font: model.menu, state: model.state, selected: model.selected)
        return cell
    }
}

extension Reactive where Base: FontCollectionView {
    /// Returns the binder that binds models to the data sources
    var models: (Observable<[FontModel]>) -> Disposable {

        // Get the binder that binds the sections to the data source
        let binder: (Observable<[FontSection]>) -> Disposable = items(dataSource: base.rxDataSource)

        // Returns the closure with the models as the inputs
        return { models in

            // Maps the models to the sections
            let sections = models.map { [FontSection(models: $0)] }

            // Binds the sections to the data source
            return binder(sections)

        }
    }

    /// Returns the stream that emits a model when it's selected
    var modelSelected: Observable<FontModel> {
        modelSelected(FontModel.self).asObservable()
    }
}
