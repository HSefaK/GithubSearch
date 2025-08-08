//
//  UserModel.swift
//  GithubSearch
//
//  Created by Hüseyin Sefa Küçük on 8.08.2025.
//

import Foundation

struct User: Codable, Equatable, Hashable {
    let id: Int
    let login: String
    let avatarUrl: String
    let htmlUrl: String
    let type: String
    let siteAdmin: Bool

    let name: String?
    let company: String?
    let blog: String?
    let location: String?
    let email: String?
    let bio: String?

    let publicRepos: Int?
    let publicGists: Int?
    let followers: Int?
    let following: Int?

    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, login, name, company, blog, location, email, bio, type, followers, following
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
        case siteAdmin = "site_admin"
        case publicRepos = "public_repos"
        case publicGists = "public_gists"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
