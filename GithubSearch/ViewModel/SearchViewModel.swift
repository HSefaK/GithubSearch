//
//  SearchViewModel.swift
//  GithubSearch
//
//  Created by Hüseyin Sefa Küçük on 8.08.2025.
//

import Foundation
import Combine
import UIKit

final class SearchViewModel {
    
    @Published private(set) var users: [User] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var searchText = ""
    
    private let networkManager = NetworkManager.shared
    private let favoritesManager = FavoritesManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var searchWorkItem: DispatchWorkItem?
    
    init() {
        setupFavoritesObserver()
    }
        
    func search(query: String) {
        searchWorkItem?.cancel()
        
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        searchText = trimmedQuery
        
        guard !trimmedQuery.isEmpty else {
            users = []
            errorMessage = nil
            return
        }
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.performSearch(query: trimmedQuery)
        }
        
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
    
    func toggleFavorite(for user: User) {
        favoritesManager.toggleFavorite(user)
        updateFavoriteStatus()
    }
    
    func isFavorite(_ user: User) -> Bool {
        return favoritesManager.isFavorite(user)
    }
    
    func clearSearch() {
        searchText = ""
        users = []
        errorMessage = nil
        searchWorkItem?.cancel()
        networkManager.cancelAllTasks()
    }
        
    private func performSearch(query: String) {
        isLoading = true
        errorMessage = nil
        
        networkManager.searchUsers(query: query) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(let response):
                self.users = response.items
                if response.items.isEmpty {
//                    self.errorMessage = "'\(query)' için sonuç bulunamadı."
                }
            case .failure(let error):
                self.users = []
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func setupFavoritesObserver() {
        NotificationCenter.default.publisher(for: FavoritesManager.favoritesDidChangeNotification)
            .sink { [weak self] _ in
                self?.updateFavoriteStatus()
            }
            .store(in: &cancellables)
    }
    
    private func updateFavoriteStatus() {
//        objectWillChange.send()
    }
}
