//
//  NetworkErrorModel.swift
//  GithubSearch
//
//  Created by Hüseyin Sefa Küçük on 8.08.2025.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkError(String)
    case rateLimitExceeded
    case serverError
    case unknown
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Geçersiz URL."
        case .noData:
            return "Veri alınamadı."
        case .decodingError:
            return "Veri işlenemedi."
        case .networkError(let message):
            return message
        case .rateLimitExceeded:
            return "API istek limiti aşıldı. Lütfen daha sonra tekrar deneyin."
        case .serverError:
            return "Sunucu tarafında bir hata oluştu."
        case .unknown:
            return "Beklenmeyen bir hata oluştu."
        }
    }
}
