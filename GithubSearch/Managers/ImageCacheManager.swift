//
//  ImageCacheManager.swift
//  GithubSearch
//
//  Created by Hüseyin Sefa Küçük on 8.08.2025.
//

import UIKit

final class ImageCacheManager {

    static let shared = ImageCacheManager()

    private let cache = NSCache<NSString, UIImage>()
    private var runningRequests = [URL: URLSessionDataTask]()

    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024
    }

    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        let cacheKey = NSString(string: urlString)

        if let cached = cache.object(forKey: cacheKey) {
            completion(cached)
            return
        }

        if runningRequests[url] != nil {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            defer { self?.runningRequests[url] = nil }

            guard
                let self = self,
                let data = data,
                error == nil,
                let image = UIImage(data: data)
            else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            self.cache.setObject(image, forKey: cacheKey)

            DispatchQueue.main.async {
                completion(image)
            }
        }

        runningRequests[url] = task
        task.resume()
    }

    func cancelLoad(for urlString: String) {
        guard let url = URL(string: urlString) else { return }
        runningRequests[url]?.cancel()
        runningRequests[url] = nil
    }

    func clear() {
        cache.removeAllObjects()
        runningRequests.values.forEach { $0.cancel() }
        runningRequests.removeAll()
    }
}


extension UIImageView {
    private struct AssociatedKeys {
        static var imageURL = "imageURL"
    }

    private var imageURL: String? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.imageURL) as? String }
        set { objc_setAssociatedObject(self, &AssociatedKeys.imageURL, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func setImage(from urlString: String, placeholder: UIImage? = nil) {
        // Cancel previous load
        if let previous = imageURL {
            ImageCacheManager.shared.cancelLoad(for: previous)
        }

        imageURL = urlString
        image = placeholder

        ImageCacheManager.shared.loadImage(from: urlString) { [weak self] downloaded in
            guard let self = self, self.imageURL == urlString else { return }

            UIView.transition(with: self,
                              duration: 0.25,
                              options: .transitionCrossDissolve,
                              animations: {
                                  self.image = downloaded ?? placeholder
                              })
        }
    }
}
