# Türkçe
## GithubSearch

GithubSearch, UIKit ile geliştirilmiş basit bir iOS uygulamasıdır. Kullanıcıların GitHub profillerini aramasına, detaylı kullanıcı bilgilerini görüntülemesine ve favori listesi oluşturmasına olanak tanır. Proje, modüler bir MVVM mimarisi ile yapılandırılmıştır ve Combine kullanılarak reaktif veri akışı sağlanmaktadır. Favori kullanıcılar UserDefaults ile kalıcı olarak saklanır. Uygulama, iyi bir kullanıcı deneyimi için yükleme göstergeleri, hata mesajları ve boş durum ekranları içerir. Doğrulama amacıyla birim ve arayüz testleri de projeye dâhildir.

### Gereksinimler

- Xcode 15 veya üzeri
- iOS 15.0 ve üzeri
- Swift 5.9 veya üzeri

### Kurulum

1. Repoyu klonlayın:  
   `git clone https://github.com/yourusername/GithubSearch.git`

2. Projeyi açın:  
   `open GithubSearch.xcodeproj`

3. Simülatörde veya fiziksel bir cihazda derleyip çalıştırın.

### Testleri Çalıştırma

Tüm birim ve arayüz testlerini çalıştırmak için projeyi Xcode'da açtıktan sonra `Command + U` kısayolunu kullanabilir veya `Product > Test` menüsüne gidebilirsiniz.

### Kullanılan API Uç Noktaları

- `GET https://api.github.com/search/users?q={query}` – GitHub kullanıcılarını arar  
- `GET https://api.github.com/users/{username}` – Belirli bir kullanıcının detaylarını getirir

### Proje Yapısı

Proje, modüler bir MVVM yapısına sahiptir:

- `View/` — Tüm ViewController’lar ve arayüz bileşenlerini içerir  
- `ViewModel/` — İş mantığı ve durum yönetimini içerir  
- `Model/` — Codable veri modellerini içerir  
- `Managers/` — Ağ işlemleri, önbellekleme ve yerel veri yöneticileri  
- `Tests/` — Unit ve UI test hedefleri

### Notlar

- Arayüz tamamen programatik olarak yazılmıştır (LaunchScreen hariç).
- Favori kullanıcılar, UserDefaults kullanılarak kalıcı olarak saklanır.
- Combine, view ve view model katmanları arasındaki veri akışını ve durum değişikliklerini yönetmek için kullanılmıştır.



# English

## GithubSearch

GithubSearch is a simple iOS application developed with UIKit. It allows users to search GitHub profiles, view detailed user information, and manage a list of favorites. The project is structured with a modular MVVM architecture and utilizes Combine for reactive data binding. Favorites are stored persistently using UserDefaults. The app includes loading indicators, error handling, and empty state views to ensure a good user experience. Unit and UI tests are also provided for validation.

GithubSearch, UIKit kullanılarak geliştirilmiş basit bir iOS uygulamasıdır. Kullanıcılar GitHub üzerinde kullanıcı araması yapabilir, detaylı kullanıcı bilgilerini görüntüleyebilir ve favori kullanıcı listesi oluşturabilir. Proje, modüler bir MVVM mimarisiyle yapılandırılmıştır ve Combine ile reaktif veri bağlama gerçekleştirilmiştir. Favori verileri UserDefaults aracılığıyla kalıcı olarak saklanır. Uygulama, iyi bir kullanıcı deneyimi sunmak amacıyla yükleme göstergeleri, hata mesajları ve boş durum ekranlarını da içermektedir. Birim (unit) ve arayüz (UI) testleri proje ile birlikte sunulmaktadır.

### Requirements

- Xcode 15 or later
- iOS 15.0+
- Swift 5.9+

### Installation

1. Clone the repository:
   `git clone https://github.com/yourusername/GithubSearch.git`
2. Open the project:
   `open GithubSearch.xcodeproj`
3. Build and run on a simulator or real device.

### Running Tests

To run all unit and UI tests, open the project in Xcode and use `Command + U` or navigate to Product > Test.

### API Endpoints Used

- `GET https://api.github.com/search/users?q={query}` – Search GitHub users
- `GET https://api.github.com/users/{username}` – Get user details

### Project Structure

The project follows a modular MVVM structure:
- `View/` contains all view controllers and UI components
- `ViewModel/` contains business logic and state management
- `Model/` includes the Codable data models
- `Managers/` includes helper services such as networking, caching, and local storage
- `Tests/` includes unit and UI test targets

### Notes

- The UI is implemented entirely programmatically, except for LaunchScreen.
- UserDefaults is used for persistent storage of favorite users.
- Combine is used to handle state changes and data flow between view and view models.
