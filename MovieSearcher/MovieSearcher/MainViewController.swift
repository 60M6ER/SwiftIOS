//
//  ViewController.swift
//  MovieSearcher
//
//  Created by Kirill Timanovsky on 29.07.2021.
//

import UIKit

final class MainViewController: UIViewController {
    private enum Constants {
        static let horizontalInset: CGFloat = 16
        static let topInset: CGFloat = 12
        static let interitemSpacing: CGFloat = 12
        static let lineSpacing: CGFloat = 20
    }

    private let searchBar = UISearchBar()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Constants.interitemSpacing
        layout.minimumLineSpacing = Constants.lineSpacing
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Ничего не найдено"
        label.isHidden = true
        return label
    }()

    private let films = TestModel.lessonSamples
    private var filteredFilms: [TestModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        filteredFilms = films
        title = "Фильмы"
        configureView()
        configureNavigationBar()
        configureSearchBar()
        configureCollectionView()
        configureLayout()
        updateEmptyState()
    }
}

private extension MainViewController {
    func configureView() {
        view.backgroundColor = .systemBackground
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(emptyStateLabel)
    }

    func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                barButtonSystemItem: .refresh,
                target: self,
                action: #selector(handleRefresh)
            ),
            UIBarButtonItem(
                image: UIImage(systemName: "heart"),
                style: .plain,
                target: self,
                action: #selector(openFavorites)
            )
        ]
    }

    func configureSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Поиск фильмов"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.returnKeyType = .search
        searchBar.autocapitalizationType = .none
    }

    func configureCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(
            top: Constants.topInset,
            left: Constants.horizontalInset,
            bottom: 24,
            right: Constants.horizontalInset
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(FilmCollectionViewCell.self, forCellWithReuseIdentifier: FilmCollectionViewCell.reuseIdentifier)
    }

    func configureLayout() {
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),

            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }

    func applySearch(text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedText.isEmpty {
            filteredFilms = films
        } else {
            filteredFilms = films.filter { $0.title.localizedCaseInsensitiveContains(trimmedText) }
        }

        collectionView.reloadData()
        updateEmptyState()
    }

    func updateEmptyState() {
        let hasFilms = !filteredFilms.isEmpty
        emptyStateLabel.isHidden = hasFilms
        collectionView.isHidden = !hasFilms
    }

    @objc func handleRefresh() {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        filteredFilms = films
        collectionView.reloadData()
        updateEmptyState()
    }

    @objc func openFavorites() {
        let controller = FavoriteFilmsViewController()
        controller.title = "Избранное"
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredFilms.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FilmCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? FilmCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: filteredFilms[indexPath.item])
        return cell
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalHorizontalPadding = (Constants.horizontalInset * 2) + Constants.interitemSpacing
        let availableWidth = collectionView.bounds.width - totalHorizontalPadding
        let cellWidth = floor(availableWidth / 2)
        return CGSize(width: cellWidth, height: cellWidth * 1.82)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let film = filteredFilms[indexPath.item]
        let controller = DetailFilmViewController()
        controller.title = film.title
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applySearch(text: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        applySearch(text: searchBar.text ?? "")
    }
}
