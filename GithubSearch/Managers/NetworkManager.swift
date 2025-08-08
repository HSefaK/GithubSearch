//
//  NetworkManager.swift
//  GithubSearch
//
//  Created by Hüseyin Sefa Küçük on 8.08.2025.
//

import Foundation

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    private let baseURL = "https://api.github.com/"
    private let session: URLSession
    private let decoder: JSONDecoder
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.waitsForConnectivity = true
        
        self.session = URLSession(configuration: configuration)
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    func searchUsers(query: String, completion: @escaping (Result<SearchResponse, NetworkError>) -> Void) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(.failure(.invalidURL))
            return
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)search/users?q=\(encodedQuery)&per_page=30"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        performRequest(url: url, completion: completion)
    }
    
    func getUserDetail(username: String, completion: @escaping (Result<User, NetworkError>) -> Void) {
        let urlString = "\(baseURL)users/\(username)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        performRequest(url: url, completion: completion)
    }
    
    private func performRequest<T: Decodable>(url: URL, completion: @escaping (Result<T, NetworkError>) -> Void) {
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error.localizedDescription)))
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    break
                case 403:
                    DispatchQueue.main.async {
                        completion(.failure(.rateLimitExceeded))
                    }
                    return
                case 500...599:
                    DispatchQueue.main.async {
                        completion(.failure(.serverError))
                    }
                    return
                default:
                    DispatchQueue.main.async {
                        completion(.failure(.unknown))
                    }
                    return
                }
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }
            
            do {
                let decodedData = try self.decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedData))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.decodingError))
                }
            }
        }
        
        task.resume()
    }
    
    func cancelAllTasks() {
        session.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }
    }
}
