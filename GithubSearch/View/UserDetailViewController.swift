//
//  UserDetailViewController.swift
//  GithubSearch
//
//  Created by Hüseyin Sefa Küçük on 8.08.2025.
//

import UIKit
import Combine

final class UserDetailViewController: UIViewController {
    
    private let viewModel: UserDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBackground
        scrollView.showsVerticalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 60
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.systemBackground.cgColor
        imageView.backgroundColor = .tertiarySystemBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let githubButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("GitHub'da Görüntüle", for: .normal)
        button.setImage(UIImage(systemName: "link"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .label
        button.tintColor = .systemBackground
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let loadingView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    init(user: User) {
        self.viewModel = UserDetailViewModel(user: user)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        configureInitialData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerView)
        headerView.addSubview(avatarImageView)
        headerView.addSubview(nameLabel)
        headerView.addSubview(usernameLabel)
        headerView.addSubview(bioLabel)
        contentView.addSubview(favoriteButton)
        contentView.addSubview(githubButton)
        contentView.addSubview(statsStackView)
        contentView.addSubview(infoStackView)
        view.addSubview(loadingView)
        
        setupStatsViews()
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            avatarImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 30),
            avatarImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarImageView.heightAnchor.constraint(equalToConstant: 120),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            usernameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            usernameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            bioLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 16),
            bioLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            bioLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            bioLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -30),
            
            favoriteButton.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            favoriteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            favoriteButton.heightAnchor.constraint(equalToConstant: 50),
            
            githubButton.topAnchor.constraint(equalTo: favoriteButton.bottomAnchor, constant: 12),
            githubButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            githubButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            githubButton.heightAnchor.constraint(equalToConstant: 50),
            
            statsStackView.topAnchor.constraint(equalTo: githubButton.bottomAnchor, constant: 30),
            statsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            statsStackView.heightAnchor.constraint(equalToConstant: 80),
            
            infoStackView.topAnchor.constraint(equalTo: statsStackView.bottomAnchor, constant: 30),
            infoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            infoStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
            
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        githubButton.addTarget(self, action: #selector(githubButtonTapped), for: .touchUpInside)
    }
    
    private func setupStatsViews() {
        let followersView = createStatView(title: "Takipçi", value: "-")
        let followingView = createStatView(title: "Takip", value: "-")
        let reposView = createStatView(title: "Repo", value: "-")
        let gistsView = createStatView(title: "Gist", value: "-")
        
        followersView.tag = 1
        followingView.tag = 2
        reposView.tag = 3
        gistsView.tag = 4
        
        statsStackView.addArrangedSubview(followersView)
        statsStackView.addArrangedSubview(followingView)
        statsStackView.addArrangedSubview(reposView)
        statsStackView.addArrangedSubview(gistsView)
    }
    
  private func createStatView(title: String, value: String) -> UIView {
      let containerView = UIView()
      containerView.backgroundColor = .secondarySystemBackground
      containerView.layer.cornerRadius = 12
      
      let valueLabel = UILabel()
      valueLabel.text = value
      valueLabel.font = .systemFont(ofSize: 22, weight: .bold)
      valueLabel.textColor = .label
      valueLabel.textAlignment = .center
      valueLabel.adjustsFontSizeToFitWidth = true
      valueLabel.minimumScaleFactor = 0.5
      valueLabel.numberOfLines = 1
      valueLabel.lineBreakMode = .byClipping
      valueLabel.translatesAutoresizingMaskIntoConstraints = false
      
      let titleLabel = UILabel()
      titleLabel.text = title
      titleLabel.font = .systemFont(ofSize: 13, weight: .regular)
      titleLabel.textColor = .secondaryLabel
      titleLabel.textAlignment = .center
      titleLabel.translatesAutoresizingMaskIntoConstraints = false
      
      containerView.addSubview(valueLabel)
      containerView.addSubview(titleLabel)
      
      NSLayoutConstraint.activate([
          valueLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
          valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
          
          titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
          titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
          titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -8)
      ])
      
      return containerView
  }

    private func createInfoView(icon: String, text: String?) -> UIView? {
        guard let text = text, !text.isEmpty else { return nil }
        
        let containerView = UIView()
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = .secondaryLabel
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            label.topAnchor.constraint(equalTo: containerView.topAnchor),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func setupBindings() {
        viewModel.$detailedUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateUI()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingView.startAnimating()
                } else {
                    self?.loadingView.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$isFavorite
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFavorite in
                self?.updateFavoriteButton(isFavorite: isFavorite)
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showError(errorMessage)
            }
            .store(in: &cancellables)
    }
    
    private func configureInitialData() {
        let user = viewModel.user
        
        avatarImageView.setImage(from: user.avatarUrl, placeholder: UIImage(systemName: "person.circle.fill"))
        nameLabel.text = user.login
        usernameLabel.text = "@\(user.login)"
        
        updateFavoriteButton(isFavorite: viewModel.isFavorite)
    }
    
    private func updateUI() {
        nameLabel.text = viewModel.displayName
        usernameLabel.text = viewModel.username
        
        bioLabel.text = viewModel.bioText
        bioLabel.isHidden = viewModel.bioText == nil
        
        updateStatView(tag: 1, value: viewModel.followersText)
        updateStatView(tag: 2, value: viewModel.followingText)
        updateStatView(tag: 3, value: viewModel.reposText)
        updateStatView(tag: 4, value: viewModel.gistsText)
        
        infoStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if let locationView = createInfoView(icon: "location.fill", text: viewModel.locationText) {
            infoStackView.addArrangedSubview(locationView)
        }
        
        if let companyView = createInfoView(icon: "building.2.fill", text: viewModel.companyText) {
            infoStackView.addArrangedSubview(companyView)
        }
        
        if let emailView = createInfoView(icon: "envelope.fill", text: viewModel.emailText) {
            infoStackView.addArrangedSubview(emailView)
        }
        
        if let blogView = createInfoView(icon: "link", text: viewModel.blogText) {
            infoStackView.addArrangedSubview(blogView)
        }
        
        if let joinDateView = createInfoView(icon: "calendar", text: viewModel.joinDateText) {
            infoStackView.addArrangedSubview(joinDateView)
        }
        
        infoStackView.isHidden = infoStackView.arrangedSubviews.isEmpty
    }
    
    private func updateStatView(tag: Int, value: String?) {
        guard let containerView = statsStackView.arrangedSubviews.first(where: { $0.tag == tag }),
              let valueLabel = containerView.subviews.first(where: { $0 is UILabel }) as? UILabel else { return }
        
        valueLabel.text = value ?? "-"
    }
    
  private func updateFavoriteButton(isFavorite: Bool) {
      favoriteButton.contentEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
      favoriteButton.titleEdgeInsets   = .init(top: 0, left: 8,  bottom: 0, right: -8)
      favoriteButton.titleLabel?.adjustsFontSizeToFitWidth = true
      favoriteButton.titleLabel?.minimumScaleFactor = 0.8
      favoriteButton.titleLabel?.lineBreakMode = .byTruncatingTail
      
      if isFavorite {
          favoriteButton.setTitle("Favorilerden Kaldır", for: .normal)
          favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
          favoriteButton.backgroundColor = .systemYellow
          favoriteButton.tintColor = .white
      } else {
          favoriteButton.setTitle("Favorilere Ekle", for: .normal)
          favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
          favoriteButton.backgroundColor = .systemBlue
          favoriteButton.tintColor = .white
      }
  }

    
    @objc private func favoriteButtonTapped() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        viewModel.toggleFavorite()
        
        UIView.animate(withDuration: 0.1, animations: {
            self.favoriteButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.favoriteButton.transform = .identity
            }
        }
    }
    
    @objc private func githubButtonTapped() {
        guard let url = viewModel.openGitHubProfile() else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        alert.addAction(UIAlertAction(title: "Tekrar Dene", style: .default) { [weak self] _ in
            self?.viewModel.refresh()
        })
        present(alert, animated: true)
    }
}
