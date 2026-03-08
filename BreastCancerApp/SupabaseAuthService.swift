import Foundation
import AuthenticationServices
import UIKit
#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

enum SupabaseAuthError: LocalizedError {
    case missingConfiguration
    case invalidEmail
    case emptyPassword
    case weakPassword
    case emailAlreadyExists
    case signUpDisabled
    case invalidCredentials
    case emailVerificationRequired
    case requestFailed
    case backendMessage(String)
    case oauthCancelled
    case oauthTokenMissing
    case oauthUserMissing
    case googleClientIDMissing
    case googleURLSchemeMissing
    case googleSDKMissing

    var errorDescription: String? {
        switch self {
        case .missingConfiguration:
            return "Supabase is not configured. Please add SUPABASE_URL and SUPABASE_ANON_KEY."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .emptyPassword:
            return "Password cannot be empty."
        case .weakPassword:
            return "Password is too weak. Use at least 6 characters."
        case .emailAlreadyExists:
            return "An account with this email already exists."
        case .signUpDisabled:
            return "Email signup is disabled in Supabase. Enable Email provider in Auth settings."
        case .invalidCredentials:
            return "Invalid email or password."
        case .emailVerificationRequired:
            return "Please verify your email, then login."
        case .requestFailed:
            return "Could not complete the request. Please try again."
        case .backendMessage(let message):
            return message
        case .oauthCancelled:
            return "Google sign in was cancelled."
        case .oauthTokenMissing:
            return "Google sign in failed to return a token."
        case .oauthUserMissing:
            return "Could not read user identity from Supabase session."
        case .googleClientIDMissing:
            return "Missing Google iOS client ID. Add GOOGLE_IOS_CLIENT_ID in Info.plist."
        case .googleURLSchemeMissing:
            return "Missing Google URL scheme. Add GOOGLE_REVERSED_CLIENT_ID and the same value in CFBundleURLSchemes."
        case .googleSDKMissing:
            return "GoogleSignIn SDK is not added to the project."
        }
    }
}

final class SupabaseAuthService {
    static let shared = SupabaseAuthService()

    private let client: SupabaseRESTClient
    private var activeOAuthSession: ASWebAuthenticationSession?
    private var activePresentationProvider: WebAuthPresentationProvider?

    init(client: SupabaseRESTClient = .shared) {
        self.client = client
    }

    func signUp(
        email: String,
        password: String,
        completion: @escaping (Result<AuthUserSupabaseRow, SupabaseAuthError>) -> Void
    ) {
        let normalizedEmail = normalize(email)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedEmail.isEmpty, normalizedEmail.contains("@") else {
            completion(.failure(.invalidEmail))
            return
        }
        guard !trimmedPassword.isEmpty else {
            completion(.failure(.emptyPassword))
            return
        }
        guard client.isConfigured else {
            completion(.failure(.missingConfiguration))
            return
        }

        let body = SupabaseSignUpRequest(email: normalizedEmail, password: trimmedPassword)
        performAuthRequest(
            method: "POST",
            path: "auth/v1/signup",
            queryItems: [],
            body: body
        ) { result in
            switch result {
            case .failure:
                completion(.failure(.requestFailed))

            case .success(let payload):
                guard (200..<300).contains(payload.statusCode) else {
                    completion(.failure(self.mapAuthFailure(statusCode: payload.statusCode, data: payload.data, isSignUp: true)))
                    return
                }

                // If email confirmation is disabled, signup usually returns a session.
                if let session = try? JSONDecoder().decode(SupabaseAuthSessionResponse.self, from: payload.data) {
                    if session.access_token != nil {
                        self.completeSupabaseSession(
                            session: session,
                            fallbackEmail: normalizedEmail,
                            completion: completion
                        )
                        return
                    }

                    // Signup succeeded but no access token => confirmation flow.
                    if session.user != nil {
                        completion(.failure(.emailVerificationRequired))
                        return
                    }
                }

                // Fallback: try password grant if backend returned an unexpected payload.
                self.signInWithPasswordSupabaseAuth(
                    email: normalizedEmail,
                    password: trimmedPassword,
                    completion: completion
                )
            }
        }
    }

    func login(
        email: String,
        password: String,
        completion: @escaping (Result<AuthUserSupabaseRow, SupabaseAuthError>) -> Void
    ) {
        let normalizedEmail = normalize(email)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedEmail.isEmpty, normalizedEmail.contains("@") else {
            completion(.failure(.invalidEmail))
            return
        }
        guard !trimmedPassword.isEmpty else {
            completion(.failure(.emptyPassword))
            return
        }
        guard client.isConfigured else {
            completion(.failure(.missingConfiguration))
            return
        }

        signInWithPasswordSupabaseAuth(
            email: normalizedEmail,
            password: trimmedPassword,
            completion: completion
        )
    }

    func markCurrentUserOnboardingCompleted() {
        guard client.isConfigured else { return }

        let userId = SupabaseUserContext.userId
        client.fetchRows(
            from: "auth_users",
            filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]
        ) { (rows: [AuthUserSupabaseRow]) in
            guard let row = rows.first else { return }
            guard row.has_completed_onboarding == false else { return }

            let updated = AuthUserSupabaseRow(
                user_id: row.user_id,
                email: row.email,
                password: row.password,
                is_logged_in: true,
                has_completed_onboarding: true,
                created_at: row.created_at,
                updated_at: Date()
            )
            self.client.upsertRows([updated], into: "auth_users", onConflict: "user_id")
        }
    }

    func signInWithGoogle(
        presentationAnchor: ASPresentationAnchor,
        completion: @escaping (Result<AuthUserSupabaseRow, SupabaseAuthError>) -> Void
    ) {
        guard let config = SupabaseConfiguration.current else {
            completion(.failure(.missingConfiguration))
            return
        }

        let callbackScheme =
            Bundle.main.object(forInfoDictionaryKey: "SUPABASE_OAUTH_REDIRECT_SCHEME") as? String
            ?? "mindooauth"
        let redirectTo = "\(callbackScheme)://oauth-callback"

        var components = URLComponents(
            url: config.url.appendingPathComponent("auth/v1/authorize"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [
            URLQueryItem(name: "provider", value: "google"),
            URLQueryItem(name: "redirect_to", value: redirectTo),
            URLQueryItem(name: "scopes", value: "openid email profile")
        ]

        guard let authURL = components?.url else {
            completion(.failure(.requestFailed))
            return
        }

        let provider = WebAuthPresentationProvider(anchor: presentationAnchor)
        let session = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: callbackScheme
        ) { [weak self] callbackURL, error in
            guard let self else { return }
            self.activeOAuthSession = nil
            self.activePresentationProvider = nil

            if let error = error as? ASWebAuthenticationSessionError,
               error.code == .canceledLogin {
                completion(.failure(.oauthCancelled))
                return
            }

            guard let callbackURL else {
                completion(.failure(.requestFailed))
                return
            }

            guard let accessToken = Self.extractOAuthValue("access_token", from: callbackURL) else {
                completion(.failure(.oauthTokenMissing))
                return
            }

            let refreshToken = Self.extractOAuthValue("refresh_token", from: callbackURL)
            let expiresIn = Self.extractOAuthValue("expires_in", from: callbackURL).flatMap(Int.init)
            self.completeSupabaseAccessToken(
                accessToken: accessToken,
                refreshToken: refreshToken,
                expiresIn: expiresIn,
                tokenType: "bearer",
                fallbackEmail: nil,
                completion: completion
            )
        }

        session.prefersEphemeralWebBrowserSession = false
        session.presentationContextProvider = provider
        self.activePresentationProvider = provider
        self.activeOAuthSession = session
        if session.start() == false {
            self.activeOAuthSession = nil
            self.activePresentationProvider = nil
            completion(.failure(.requestFailed))
        }
    }

    func signInWithGoogleNative(
        presentingViewController: UIViewController,
        completion: @escaping (Result<AuthUserSupabaseRow, SupabaseAuthError>) -> Void
    ) {
#if canImport(GoogleSignIn)
        guard let clientID = Self.googleIOSClientID() else {
            completion(.failure(.googleClientIDMissing))
            return
        }
        guard let reversedClientID = Self.googleReversedClientID(),
              Self.hasURLScheme(reversedClientID) else {
            completion(.failure(.googleURLSchemeMissing))
            return
        }

        let configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = configuration

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            if let error {
                let nsError = error as NSError
                if nsError.domain == "com.google.GIDSignIn",
                   nsError.code == -5 {
                    completion(.failure(.oauthCancelled))
                } else {
                    completion(.failure(.requestFailed))
                }
                return
            }

            guard let user = result?.user else {
                completion(.failure(.requestFailed))
                return
            }

            guard let idToken = user.idToken?.tokenString, !idToken.isEmpty else {
                completion(.failure(.oauthTokenMissing))
                return
            }

            let fallbackEmail = user.profile?.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let googleAccessToken = user.accessToken.tokenString
            self.signInWithGoogleIDTokenSupabaseAuth(
                idToken: idToken,
                accessToken: googleAccessToken,
                fallbackEmail: fallbackEmail,
                completion: completion
            )
        }
#else
        completion(.failure(.googleSDKMissing))
#endif
    }

    func handleGoogleOpenURL(_ url: URL) -> Bool {
#if canImport(GoogleSignIn)
        return GIDSignIn.sharedInstance.handle(url)
#else
        return false
#endif
    }

    private func normalize(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static func googleIOSClientID() -> String? {
        if let direct = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_IOS_CLIENT_ID") as? String,
           !direct.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           direct != "REPLACE_WITH_GOOGLE_IOS_CLIENT_ID" {
            return direct
        }

        if let legacyClientID = Bundle.main.object(forInfoDictionaryKey: "CLIENT_ID") as? String,
           !legacyClientID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return legacyClientID
        }

        return nil
    }

    private static func googleReversedClientID() -> String? {
        if let direct = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_REVERSED_CLIENT_ID") as? String {
            let trimmed = direct.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty, trimmed != "REPLACE_WITH_GOOGLE_REVERSED_CLIENT_ID" {
                return trimmed
            }
        }

        guard let clientID = googleIOSClientID() else {
            return nil
        }
        let suffix = ".apps.googleusercontent.com"
        guard clientID.hasSuffix(suffix) else {
            return nil
        }

        let prefix = String(clientID.dropLast(suffix.count))
        return "com.googleusercontent.apps.\(prefix)"
    }

    private static func hasURLScheme(_ scheme: String) -> Bool {
        let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]] ?? []
        for type in urlTypes {
            let schemes = type["CFBundleURLSchemes"] as? [String] ?? []
            if schemes.contains(scheme) {
                return true
            }
        }
        return false
    }

    private func signInWithPasswordSupabaseAuth(
        email: String,
        password: String,
        completion: @escaping (Result<AuthUserSupabaseRow, SupabaseAuthError>) -> Void
    ) {
        let body = SupabasePasswordGrantRequest(email: email, password: password)
        performAuthRequest(
            method: "POST",
            path: "auth/v1/token",
            queryItems: [URLQueryItem(name: "grant_type", value: "password")],
            body: body
        ) { result in
            switch result {
            case .failure:
                completion(.failure(.requestFailed))

            case .success(let payload):
                guard (200..<300).contains(payload.statusCode) else {
                    completion(.failure(self.mapAuthFailure(statusCode: payload.statusCode, data: payload.data, isSignUp: false)))
                    return
                }
                guard let session = try? JSONDecoder().decode(SupabaseAuthSessionResponse.self, from: payload.data) else {
                    completion(.failure(.requestFailed))
                    return
                }
                self.completeSupabaseSession(session: session, fallbackEmail: email, completion: completion)
            }
        }
    }

    private func signInWithGoogleIDTokenSupabaseAuth(
        idToken: String,
        accessToken: String?,
        fallbackEmail: String?,
        completion: @escaping (Result<AuthUserSupabaseRow, SupabaseAuthError>) -> Void
    ) {
        let body = SupabaseIDTokenGrantRequest(
            provider: "google",
            id_token: idToken,
            access_token: accessToken
        )
        performAuthRequest(
            method: "POST",
            path: "auth/v1/token",
            queryItems: [URLQueryItem(name: "grant_type", value: "id_token")],
            body: body
        ) { result in
            switch result {
            case .failure:
                completion(.failure(.requestFailed))

            case .success(let payload):
                guard (200..<300).contains(payload.statusCode) else {
                    completion(.failure(self.mapAuthFailure(statusCode: payload.statusCode, data: payload.data, isSignUp: false)))
                    return
                }
                guard let session = try? JSONDecoder().decode(SupabaseAuthSessionResponse.self, from: payload.data) else {
                    completion(.failure(.requestFailed))
                    return
                }
                self.completeSupabaseSession(session: session, fallbackEmail: fallbackEmail, completion: completion)
            }
        }
    }

    private func completeSupabaseSession(
        session: SupabaseAuthSessionResponse,
        fallbackEmail: String?,
        completion: @escaping (Result<AuthUserSupabaseRow, SupabaseAuthError>) -> Void
    ) {
        guard let accessToken = session.access_token, !accessToken.isEmpty else {
            completion(.failure(.oauthTokenMissing))
            return
        }
        completeSupabaseAccessToken(
            accessToken: accessToken,
            refreshToken: session.refresh_token,
            expiresIn: session.expires_in,
            tokenType: session.token_type,
            fallbackEmail: fallbackEmail ?? session.user?.email,
            completion: completion
        )
    }

    private func completeSupabaseAccessToken(
        accessToken: String,
        refreshToken: String?,
        expiresIn: Int?,
        tokenType: String?,
        fallbackEmail: String?,
        completion: @escaping (Result<AuthUserSupabaseRow, SupabaseAuthError>) -> Void
    ) {
        SupabaseAuthSessionStore.set(
            accessToken: accessToken,
            refreshToken: refreshToken,
            tokenType: tokenType,
            expiresIn: expiresIn
        )

        fetchSupabaseAuthUser(accessToken: accessToken) { user in
            guard let user,
                  let userId = UUID(uuidString: user.id) else {
                completion(.failure(.oauthUserMissing))
                return
            }

            let normalizedEmail =
                user.email?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                ?? fallbackEmail
                ?? ""

            self.upsertAppAuthUser(
                userId: userId,
                email: normalizedEmail,
                completion: completion
            )
        }
    }

    private func fetchSupabaseAuthUser(accessToken: String, completion: @escaping (SupabaseAuthAPIUser?) -> Void) {
        performAuthRequest(
            method: "GET",
            path: "auth/v1/user",
            queryItems: [],
            bearerToken: accessToken,
            body: Optional<Data>.none
        ) { result in
            switch result {
            case .failure:
                completion(nil)
            case .success(let payload):
                guard (200..<300).contains(payload.statusCode) else {
                    completion(nil)
                    return
                }
                completion(try? JSONDecoder().decode(SupabaseAuthAPIUser.self, from: payload.data))
            }
        }
    }

    private func upsertAppAuthUser(
        userId: UUID,
        email: String,
        completion: @escaping (Result<AuthUserSupabaseRow, SupabaseAuthError>) -> Void
    ) {
        let normalizedEmail = normalize(email)
        client.fetchRows(
            from: "auth_users",
            filters: [SupabaseFilter(key: "user_id", op: "eq", value: userId.uuidString)]
        ) { (rows: [AuthUserSupabaseRow]) in
            if let existing = rows.first {
                let updated = AuthUserSupabaseRow(
                    user_id: userId,
                    email: normalizedEmail.isEmpty ? existing.email : normalizedEmail,
                    password: existing.password,
                    is_logged_in: true,
                    has_completed_onboarding: existing.has_completed_onboarding,
                    created_at: existing.created_at,
                    updated_at: Date()
                )
                self.client.upsertRows([updated], into: "auth_users", onConflict: "user_id") { success in
                    guard success else {
                        completion(.failure(.requestFailed))
                        return
                    }
                    SupabaseUserContext.setUser(id: userId, email: updated.email)
                    completion(.success(updated))
                }
                return
            }

            guard !normalizedEmail.isEmpty else {
                completion(.failure(.oauthUserMissing))
                return
            }

            let created = AuthUserSupabaseRow(
                user_id: userId,
                email: normalizedEmail,
                password: "SUPABASE_AUTH_MANAGED",
                is_logged_in: true,
                has_completed_onboarding: false,
                created_at: Date(),
                updated_at: Date()
            )
            self.client.upsertRows([created], into: "auth_users", onConflict: "user_id") { success in
                guard success else {
                    completion(.failure(.requestFailed))
                    return
                }
                SupabaseUserContext.setUser(id: userId, email: created.email)
                completion(.success(created))
            }
        }
    }

    private func performAuthRequest<T: Encodable>(
        method: String,
        path: String,
        queryItems: [URLQueryItem],
        bearerToken: String? = nil,
        body: T?,
        completion: @escaping (Result<(statusCode: Int, data: Data), URLError>) -> Void
    ) {
        guard let config = SupabaseConfiguration.current else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var components = URLComponents(
            url: config.url.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        guard let url = components?.url else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(config.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken ?? config.anonKey)", forHTTPHeaderField: "Authorization")

        if let body {
            request.httpBody = try? JSONEncoder().encode(body)
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error as? URLError {
                completion(.failure(error))
                return
            }

            guard let http = response as? HTTPURLResponse else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            completion(.success((statusCode: http.statusCode, data: data ?? Data())))
        }.resume()
    }

    private func mapAuthFailure(statusCode: Int, data: Data, isSignUp: Bool) -> SupabaseAuthError {
        if let payload = try? JSONDecoder().decode(SupabaseAuthAPIError.self, from: data) {
            return mapAuthError(payload, fallback: .requestFailed, isSignUp: isSignUp)
        }

        if let extractedMessage = extractErrorMessage(from: data) {
            let raw = extractedMessage.lowercased()
            if isSignUp && (raw.contains("already") || raw.contains("registered") || raw.contains("exists")) {
                return .emailAlreadyExists
            }
            if raw.contains("email not confirmed") || raw.contains("confirm") {
                return .emailVerificationRequired
            }
            if raw.contains("signup") && (raw.contains("disabled") || raw.contains("not allowed")) {
                return .signUpDisabled
            }
            if raw.contains("email provider is disabled") {
                return .signUpDisabled
            }
            if raw.contains("password") && (raw.contains("least") || raw.contains("weak") || raw.contains("short")) {
                return .weakPassword
            }
            if raw.contains("rate limit") && raw.contains("email") {
                return .backendMessage("Too many signup attempts. Please wait a few minutes, or use Login if this email already has an account.")
            }
            if raw.contains("invalid login credentials")
                || raw.contains("invalid credentials")
                || raw.contains("invalid grant")
                || raw.contains("bad oauth state")
                || raw.contains("no valid flow state found") {
                return .invalidCredentials
            }
            return .backendMessage(extractedMessage)
        }

        if statusCode == 400 || statusCode == 401 {
            return .invalidCredentials
        }
        return .requestFailed
    }

    private func mapAuthError(_ payload: SupabaseAuthAPIError, fallback: SupabaseAuthError, isSignUp: Bool) -> SupabaseAuthError {
        let raw = [
            payload.message,
            payload.msg,
            payload.error_description,
            payload.error,
            payload.code
        ]
        .compactMap { $0?.lowercased() }
        .joined(separator: " ")

        if isSignUp && (raw.contains("already") || raw.contains("registered") || raw.contains("exists")) {
            return .emailAlreadyExists
        }

        if raw.contains("email not confirmed") || raw.contains("confirm") {
            return .emailVerificationRequired
        }

        if raw.contains("signup") && (raw.contains("disabled") || raw.contains("not allowed")) {
            return .signUpDisabled
        }

        if raw.contains("email provider is disabled") {
            return .signUpDisabled
        }

        if raw.contains("password") && (raw.contains("least") || raw.contains("weak") || raw.contains("short")) {
            return .weakPassword
        }

        if raw.contains("rate limit") && raw.contains("email") {
            return .backendMessage("Too many signup attempts. Please wait a few minutes, or use Login if this email already has an account.")
        }

        if raw.contains("invalid login credentials")
            || raw.contains("invalid credentials")
            || raw.contains("invalid grant")
            || raw.contains("bad oauth state")
            || raw.contains("no valid flow state found") {
            return .invalidCredentials
        }

        if let message = payload.message ?? payload.msg ?? payload.error_description ?? payload.error,
           !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .backendMessage(message)
        }

        return fallback
    }

    private func extractErrorMessage(from data: Data) -> String? {
        guard !data.isEmpty else { return nil }
        if let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            let keys = ["message", "msg", "error_description", "error", "code"]
            for key in keys {
                if let value = object[key] as? String,
                   !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return value
                }
            }
        }
        return nil
    }

    private static func extractOAuthValue(_ key: String, from url: URL) -> String? {
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        if let queryValue = queryItems.first(where: { $0.name == key })?.value, !queryValue.isEmpty {
            return queryValue
        }

        guard let fragment = URLComponents(url: url, resolvingAgainstBaseURL: false)?.fragment else {
            return nil
        }
        let items = fragment.split(separator: "&")
        for item in items {
            let pair = item.split(separator: "=", maxSplits: 1).map(String.init)
            if pair.count == 2, pair[0] == key {
                return pair[1].removingPercentEncoding ?? pair[1]
            }
        }
        return nil
    }
}

private struct SupabaseAuthSessionResponse: Decodable {
    let access_token: String?
    let refresh_token: String?
    let token_type: String?
    let expires_in: Int?
    let user: SupabaseAuthAPIUser?
}

private struct SupabaseAuthAPIUser: Decodable {
    let id: String
    let email: String?
}

private struct SupabaseAuthAPIError: Decodable {
    let code: String?
    let error: String?
    let error_description: String?
    let msg: String?
    let message: String?
}

private struct SupabaseSignUpRequest: Encodable {
    let email: String
    let password: String
}

private struct SupabasePasswordGrantRequest: Encodable {
    let email: String
    let password: String
}

private struct SupabaseIDTokenGrantRequest: Encodable {
    let provider: String
    let id_token: String
    let access_token: String?
}

private final class WebAuthPresentationProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    private let anchor: ASPresentationAnchor

    init(anchor: ASPresentationAnchor) {
        self.anchor = anchor
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        anchor
    }
}
