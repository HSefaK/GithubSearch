//
//  GithubSearchTests.swift
//  GithubSearchTests
//
//  Created by Hüseyin Sefa Küçük on 8.08.2025.
//

import XCTest
@testable import GithubSearch

final class GithubSearchTests: XCTestCase {

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }

    func testExample() throws {
        XCTAssertTrue(true, "Basic test should pass")
    }

    func testPerformanceExample() throws {
        self.measure {
            let _ = Array(0...100).map { $0 * 2 }
        }
    }
}

class FavoritesManagerTests: XCTestCase {
    
    var favoritesManager: FavoritesManager!
    var testUser: User!
    var uniqueTestKey: String!
    
    override func setUp() {
        super.setUp()
        
        uniqueTestKey = "test_favorites_\(UUID().uuidString)"
        
        UserDefaults.standard.removeObject(forKey: "com.githubusers.favorites")
        UserDefaults.standard.synchronize()
        
        favoritesManager = FavoritesManager.shared
        
        testUser = User(
            id: Int.random(in: 100000...999999),
            login: "testuser_\(Int.random(in: 1000...9999))",
            avatarUrl: "https://example.com/avatar.jpg",
            htmlUrl: "https://github.com/testuser",
            type: "User",
            siteAdmin: false,
            name: "Test User",
            company: nil,
            blog: nil,
            location: nil,
            email: nil,
            bio: nil,
            publicRepos: 10,
            publicGists: 5,
            followers: 100,
            following: 50,
            createdAt: "2020-01-01T00:00:00Z",
            updatedAt: "2023-01-01T00:00:00Z"
        )
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "com.githubusers.favorites")
        UserDefaults.standard.synchronize()
        super.tearDown()
    }
    
    func testAddFavorite() {
        let initialCount = favoritesManager.getFavorites().count
        
        favoritesManager.addFavorite(testUser)
        
        let finalCount = favoritesManager.getFavorites().count
        XCTAssertEqual(finalCount, initialCount + 1, "Should have one more favorite")
        XCTAssertTrue(favoritesManager.isFavorite(testUser), "User should be marked as favorite")
    }
    
    func testRemoveFavorite() {
        favoritesManager.addFavorite(testUser)
        XCTAssertTrue(favoritesManager.isFavorite(testUser), "Setup: User should be favorite")
        
        favoritesManager.removeFavorite(testUser)
        
        XCTAssertFalse(favoritesManager.isFavorite(testUser), "User should not be favorite after removal")
        XCTAssertEqual(favoritesManager.getFavorites().count, 0, "Should have no favorites")
    }
    
    func testToggleFavorite() {
        XCTAssertFalse(favoritesManager.isFavorite(testUser), "User should not be favorite initially")
        
        favoritesManager.toggleFavorite(testUser)
        XCTAssertTrue(favoritesManager.isFavorite(testUser), "User should be favorite after toggle")
        
        favoritesManager.toggleFavorite(testUser)
        XCTAssertFalse(favoritesManager.isFavorite(testUser), "User should not be favorite after second toggle")
    }
    
    func testPreventDuplicateFavorites() {
        favoritesManager.addFavorite(testUser)
        let countAfterFirst = favoritesManager.getFavorites().count
        
        favoritesManager.addFavorite(testUser)
        let countAfterSecond = favoritesManager.getFavorites().count
        
        XCTAssertEqual(countAfterFirst, countAfterSecond, "Should prevent duplicate favorites")
    }
}

class SearchViewModelTests: XCTestCase {
    
    var viewModel: SearchViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = SearchViewModel()
    }
    
    func testSearchWithValidQuery() {
        let query = "octocat"
        
        viewModel.search(query: query)
        
        XCTAssertEqual(viewModel.searchText, query, "Search text should be updated immediately")
    }
    
    func testSearchWithEmptyQuery() {
        let query = ""
        
        viewModel.search(query: query)
        
        XCTAssertEqual(viewModel.users.count, 0, "Users should be empty for empty query")
        XCTAssertEqual(viewModel.searchText, "", "Search text should be empty")
    }
    
    func testClearSearch() {
        viewModel.search(query: "test")
        XCTAssertEqual(viewModel.searchText, "test", "Setup: search text should be set")
        
        viewModel.clearSearch()
        
        XCTAssertEqual(viewModel.searchText, "", "Search text should be cleared")
        XCTAssertEqual(viewModel.users.count, 0, "Users array should be cleared")
        XCTAssertNil(viewModel.errorMessage, "Error message should be cleared")
    }
    
    func testSearchTextTrimming() {
        let query = "  octocat  "
        
        viewModel.search(query: query)
        
        XCTAssertEqual(viewModel.searchText, "octocat", "Search text should be trimmed")
    }
}

class UserModelTests: XCTestCase {
    
    func testUserEquality() {
        let user1 = User(
            id: 123,
            login: "testuser1",
            avatarUrl: "url1",
            htmlUrl: "html1",
            type: "User",
            siteAdmin: false,
            name: nil, company: nil, blog: nil, location: nil, email: nil, bio: nil,
            publicRepos: nil, publicGists: nil, followers: nil, following: nil,
            createdAt: nil, updatedAt: nil
        )
        
        let user2 = User(
            id: 123,
            login: "testuser2",
            avatarUrl: "url2",
            htmlUrl: "html2",
            type: "User",
            siteAdmin: false,
            name: nil, company: nil, blog: nil, location: nil, email: nil, bio: nil,
            publicRepos: nil, publicGists: nil, followers: nil, following: nil,
            createdAt: nil, updatedAt: nil
        )
        
        XCTAssertEqual(user1, user2, "Users with same ID should be equal")
    }
    
    func testUserInequality() {
        let user1 = User(
            id: 123, login: "user1", avatarUrl: "", htmlUrl: "", type: "User", siteAdmin: false,
            name: nil, company: nil, blog: nil, location: nil, email: nil, bio: nil,
            publicRepos: nil, publicGists: nil, followers: nil, following: nil,
            createdAt: nil, updatedAt: nil
        )
        
        let user2 = User(
            id: 456, login: "user2", avatarUrl: "", htmlUrl: "", type: "User", siteAdmin: false,
            name: nil, company: nil, blog: nil, location: nil, email: nil, bio: nil,
            publicRepos: nil, publicGists: nil, followers: nil, following: nil,
            createdAt: nil, updatedAt: nil
        )
        
        XCTAssertNotEqual(user1, user2, "Users with different IDs should not be equal")
    }
    
    func testUserDecoding() {
        let jsonData = """
        {
            "id": 583231,
            "login": "octocat",
            "avatar_url": "https://avatars3.githubusercontent.com/u/583231?v=4",
            "html_url": "https://github.com/octocat",
            "type": "User",
            "site_admin": false
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let user = try decoder.decode(User.self, from: jsonData)
            
            XCTAssertEqual(user.id, 583231, "User ID should be decoded correctly")
            XCTAssertEqual(user.login, "octocat", "User login should be decoded correctly")
            XCTAssertEqual(user.type, "User", "User type should be decoded correctly")
            XCTAssertFalse(user.siteAdmin, "User site_admin should be decoded correctly")
            XCTAssertEqual(user.avatarUrl, "https://avatars3.githubusercontent.com/u/583231?v=4", "Avatar URL should be decoded correctly")
        } catch {
            XCTFail("Decoding should not fail: \(error)")
        }
    }
}

class UserDetailViewModelTests: XCTestCase {
    
    var basicUser: User!
    
    override func setUp() {
        super.setUp()
        
        basicUser = User(
            id: 583231,
            login: "octocat",
            avatarUrl: "https://avatars3.githubusercontent.com/u/583231?v=4",
            htmlUrl: "https://github.com/octocat",
            type: "User",
            siteAdmin: false,
            name: nil,
            company: nil,
            blog: nil,
            location: nil,
            email: nil,
            bio: nil,
            publicRepos: nil,
            publicGists: nil,
            followers: nil,
            following: nil,
            createdAt: nil,
            updatedAt: nil
        )
    }
    
    func testDisplayNameFallback() {
        let viewModel = UserDetailViewModel(user: basicUser)
        
        XCTAssertEqual(viewModel.displayName, "octocat", "Should fallback to login when name is nil")
    }
    
    func testUsername() {
        let viewModel = UserDetailViewModel(user: basicUser)
        
        XCTAssertEqual(viewModel.username, "@octocat", "Username should be formatted with @ prefix")
    }
    
    func testOpenGitHubProfile() {
        let viewModel = UserDetailViewModel(user: basicUser)
        
        let url = viewModel.openGitHubProfile()
        XCTAssertNotNil(url, "GitHub profile URL should not be nil")
        XCTAssertEqual(url?.absoluteString, "https://github.com/octocat", "Should return correct GitHub URL")
    }
    
    func testInitialState() {
        let viewModel = UserDetailViewModel(user: basicUser)
        
        XCTAssertEqual(viewModel.user.id, 583231, "User should be set correctly")
        XCTAssertTrue(viewModel.isLoading, "Should be loading initially because loadUserDetail is called in init")
        XCTAssertNil(viewModel.errorMessage, "Should not have error initially")
        XCTAssertNil(viewModel.detailedUser, "DetailedUser should be nil initially")
    }
    
    func testComputedPropertiesWithNilDetailedUser() {
        let viewModel = UserDetailViewModel(user: basicUser)
        
        XCTAssertNil(viewModel.bioText, "Bio text should be nil when detailedUser is nil")
        XCTAssertNil(viewModel.followersText, "Followers text should be nil when detailedUser is nil")
        XCTAssertNil(viewModel.blogText, "Blog text should be nil when detailedUser is nil")
        XCTAssertNil(viewModel.reposText, "Repos text should be nil when detailedUser is nil")
        XCTAssertNil(viewModel.locationText, "Location text should be nil when detailedUser is nil")
        XCTAssertNil(viewModel.companyText, "Company text should be nil when detailedUser is nil")
        XCTAssertNil(viewModel.emailText, "Email text should be nil when detailedUser is nil")
        XCTAssertNil(viewModel.gistsText, "Gists text should be nil when detailedUser is nil")
        XCTAssertNil(viewModel.followingText, "Following text should be nil when detailedUser is nil")
        XCTAssertNil(viewModel.joinDateText, "Join date text should be nil when detailedUser is nil")
    }
}

class PerformanceTests: XCTestCase {
    
    func testArrayCreationPerformance() {
        measure {
            let _ = Array(0..<1000).map { $0 * 2 }
        }
    }
    
    func testUserCreationPerformance() {
        measure {
            for i in 0..<100 {
                let _ = User(
                    id: i, login: "user\(i)", avatarUrl: "", htmlUrl: "", type: "User", siteAdmin: false,
                    name: nil, company: nil, blog: nil, location: nil, email: nil, bio: nil,
                    publicRepos: nil, publicGists: nil, followers: nil, following: nil,
                    createdAt: nil, updatedAt: nil
                )
            }
        }
    }
}
