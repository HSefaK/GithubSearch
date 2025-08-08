//
//  UserDetailViewModel.swift
//  GithubSearch
//
//  Created by Hüseyin Sefa Küçük on 8.08.2025.
//

import Foundation
import Combine

final class UserDetailViewModel {

    @Published private(set) var user: User
    @Published private(set) var detailedUser: User?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isFavorite: Bool = false
    @Published private(set) var errorMessage: String?

    private let networkManager = NetworkManager.shared
    private let favoritesManager = FavoritesManager.shared
    private var cancellables = Set<AnyCancellable>()

    init(user: User, loadDetails: Bool = true) {
        self.user = user
        self.isFavorite = favoritesManager.isFavorite(user)

        setupFavoritesObserver()
        if loadDetails {
            loadUserDetail()
        }
    }

    func toggleFavorite() {
        let target = detailedUser ?? user
        favoritesManager.toggleFavorite(target)
        isFavorite = favoritesManager.isFavorite(target)
    }

    func refresh() {
        loadUserDetail()
    }

    func openGitHubProfile() -> URL? {
        let urlString = detailedUser?.htmlUrl ?? user.htmlUrl
        return URL(string: urlString)
    }

    var displayName: String {
        detailedUser?.name?.isEmpty == false ? detailedUser!.name! : user.login
    }

    var username: String {
        "@\(user.login)"
    }

    var bioText: String? {
        detailedUser?.bio
    }

    var locationText: String? {
        detailedUser?.location
    }

    var companyText: String? {
        detailedUser?.company
    }

    var blogText: String? {
        guard let blog = detailedUser?.blog?.trimmingCharacters(in: .whitespacesAndNewlines),
              !blog.isEmpty else { return nil }
        return blog.hasPrefix("http") ? blog : "https://\(blog)"
    }

    var emailText: String? {
        detailedUser?.email
    }

    var followersText: String? {
        detailedUser?.followers.map(formatNumber)
    }

    var followingText: String? {
        detailedUser?.following.map(formatNumber)
    }

    var reposText: String? {
        detailedUser?.publicRepos.map(String.init)
    }

    var gistsText: String? {
        detailedUser?.publicGists.map(String.init)
    }

    var joinDateText: String? {
        guard let createdAt = detailedUser?.createdAt else { return nil }

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        guard let date = inputFormatter.date(from: createdAt) else { return nil }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM yyyy"
        outputFormatter.locale = Locale(identifier: "tr_TR")

        return "Katılım: \(outputFormatter.string(from: date))"
    }

    private func loadUserDetail() {
        isLoading = true
        errorMessage = nil

        networkManager.getUserDetail(username: user.login) { [weak self] result in
            guard let self = self else { return }

            self.isLoading = false

            switch result {
            case .success(let detailedUser):
                self.detailedUser = detailedUser
                self.user = detailedUser
                self.isFavorite = self.favoritesManager.isFavorite(detailedUser)
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func setupFavoritesObserver() {
        NotificationCenter.default
            .publisher(for: FavoritesManager.favoritesDidChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                let current = self.detailedUser ?? self.user
                self.isFavorite = self.favoritesManager.isFavorite(current)
            }
            .store(in: &cancellables)
    }

    private func formatNumber(_ number: Int) -> String {
        switch number {
        case 1_000_000...:
            return String(format: "%.1fM", Double(number) / 1_000_000)
        case 1_000...:
            return String(format: "%.1fK", Double(number) / 1_000)
        default:
            return "\(number)"
        }
    }
}
