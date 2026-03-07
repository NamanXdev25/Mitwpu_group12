import Foundation

enum AppBackendProvider: String {
    case firestore
    case supabase
}

enum AppBackend {
    private static let key = "selected_app_backend"

    static var current: AppBackendProvider {
        if let rawValue = UserDefaults.standard.string(forKey: key),
           let provider = AppBackendProvider(rawValue: rawValue) {
            return provider
        }

        if SupabaseConfiguration.current != nil {
            return .supabase
        }

        return .firestore
    }

    static func setCurrent(_ provider: AppBackendProvider) {
        UserDefaults.standard.set(provider.rawValue, forKey: key)
    }
}
