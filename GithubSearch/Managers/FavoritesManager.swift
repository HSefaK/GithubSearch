//
//  FavoritesManager.swift
//  GithubSearch
//
//  Created by Hüseyin Sefa Küçük on 8.08.2025.
//

import Foundation

final class FavoritesManager {

    static let shared = FavoritesManager()

    private let favoritesKey = "com.githubusers.favorites"
    private let userDefaults = UserDefaults.standard

    static let favoritesDidChangeNotification = Notification.Name("FavoritesDidChangeNotification")

    private init() {}

    func getFavorites() -> [User] {
        guard let data = userDefaults.data(forKey: favoritesKey) else { return [] }
        return (try? JSONDecoder().decode([User].self, from: data)) ?? []
    }

    func addFavorite(_ user: User) {
        var favorites = getFavorites()

        guard !favorites.contains(where: { $0.id == user.id }) else { return }

        favorites.append(user)
        saveFavorites(favorites)
    }

    func removeFavorite(_ user: User) {
        var favorites = getFavorites()
        favorites.removeAll { $0.id == user.id }
        saveFavorites(favorites)
    }

    func toggleFavorite(_ user: User) {
        isFavorite(user) ? removeFavorite(user) : addFavorite(user)
    }

    func isFavorite(_ user: User) -> Bool {
        return getFavorites().contains(where: { $0.id == user.id })
    }

    func isFavorite(userId: Int) -> Bool {
        return getFavorites().contains(where: { $0.id == userId })
    }

    private func saveFavorites(_ favorites: [User]) {
        guard let data = try? JSONEncoder().encode(favorites) else { return }
        userDefaults.set(data, forKey: favoritesKey)
        postFavoritesChanged()
    }

    private func postFavoritesChanged() {
        NotificationCenter.default.post(name: Self.favoritesDidChangeNotification, object: nil)
    }
}
