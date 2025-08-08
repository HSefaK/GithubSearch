//
//  FavoritesViewModel.swift
//  GithubSearch
//
//  Created by Hüseyin Sefa Küçük on 8.08.2025.
//

import Foundation
import Combine

final class FavoritesViewModel {

    @Published private(set) var favorites: [User] = []
    @Published private(set) var isLoading: Bool = false

    var isEmpty: Bool {
        favorites.isEmpty
    }

    var emptyMessage: String {
        "Henüz favori kullanıcı eklemediniz.\nArama sekmesinden kullanıcı arayarak favorilere ekleyebilirsiniz."
    }

    private let favoritesManager = FavoritesManager.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupFavoritesObserver()
        loadFavorites()
    }

    func loadFavorites() {
        isLoading = true
        favorites = favoritesManager.getFavorites()
        isLoading = false
    }

    func removeFavorite(_ user: User) {
        favoritesManager.removeFavorite(user)
        loadFavorites()
    }

    func removeFavorite(at index: Int) {
        guard index < favorites.count else { return }
        let user = favorites[index]
        removeFavorite(user)
    }

    private func setupFavoritesObserver() {
        NotificationCenter.default
            .publisher(for: FavoritesManager.favoritesDidChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadFavorites()
            }
            .store(in: &cancellables)
    }
}
