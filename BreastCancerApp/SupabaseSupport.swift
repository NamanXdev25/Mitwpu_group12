import Foundation

struct SupabaseConfiguration {
    let url: URL
    let anonKey: String
    let schema: String

    static var current: SupabaseConfiguration? {
        let defaults = UserDefaults.standard

        let urlString =
            defaults.string(forKey: "SUPABASE_URL")
            ?? Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String
        let anonKey =
            defaults.string(forKey: "SUPABASE_ANON_KEY")
            ?? Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String
        let schema =
            defaults.string(forKey: "SUPABASE_SCHEMA")
            ?? Bundle.main.object(forInfoDictionaryKey: "SUPABASE_SCHEMA") as? String
            ?? "public"

        guard let urlString, let anonKey, let url = URL(string: urlString), !anonKey.isEmpty else {
            return nil
        }

        return SupabaseConfiguration(url: url, anonKey: anonKey, schema: schema)
    }
}

enum SupabaseUserContext {
    private static let key = "supabase_user_id"

    static var userId: UUID {
        if let rawValue = UserDefaults.standard.string(forKey: key),
           let uuid = UUID(uuidString: rawValue) {
            return uuid
        }

        let generated = UUID()
        UserDefaults.standard.set(generated.uuidString, forKey: key)
        return generated
    }
}

struct SupabaseFilter {
    let key: String
    let op: String
    let value: String

    func asQueryItem() -> URLQueryItem {
        URLQueryItem(name: key, value: "\(op).\(value)")
    }
}

final class SupabaseRESTClient {
    static let shared = SupabaseRESTClient()

    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let writeQueue = DispatchQueue(label: "BreastCancerApp.SupabaseRESTClient.writeQueue")

    init(session: URLSession = .shared) {
        self.session = session

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    var isConfigured: Bool {
        SupabaseConfiguration.current != nil
    }

    func fetchRows<T: Decodable>(
        from table: String,
        filters: [SupabaseFilter] = [],
        completion: @escaping ([T]) -> Void
    ) {
        guard let request = makeRequest(method: "GET", table: table, filters: filters, onConflict: nil) else {
            print("Supabase fetch skipped: missing configuration for table", table)
            completion([])
            return
        }

        session.dataTask(with: request) { [decoder] data, response, _ in
            guard let data else {
                print("Supabase fetch returned no data for table", table)
                completion([])
                return
            }

            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                print("Supabase fetch failed:", table, "status:", http.statusCode)
                if let body = String(data: data, encoding: .utf8) {
                    print("Supabase fetch body:", body)
                }
            }
            let rows = (try? decoder.decode([T].self, from: data)) ?? []
            completion(rows)
        }.resume()
    }

    func upsertRows<T: Encodable>(
        _ rows: [T],
        into table: String,
        onConflict: String? = "id",
        completion: ((Bool) -> Void)? = nil
    ) {
        guard !rows.isEmpty else {
            completion?(true)
            return
        }

        guard let request = makeRequest(
            method: "POST",
            table: table,
            filters: [],
            onConflict: onConflict,
            body: rows
        ) else {
            print("Supabase upsert skipped: missing configuration for table", table)
            completion?(false)
            return
        }

        writeQueue.async {
            let success = self.performWrite(request, action: "upsert", table: table)
            DispatchQueue.main.async {
                completion?(success)
            }
        }
    }

    func deleteRows(
        from table: String,
        filters: [SupabaseFilter],
        completion: ((Bool) -> Void)? = nil
    ) {
        guard !filters.isEmpty else {
            completion?(false)
            return
        }

        guard let request = makeRequest(method: "DELETE", table: table, filters: filters, onConflict: nil) else {
            print("Supabase delete skipped: missing configuration for table", table)
            completion?(false)
            return
        }

        writeQueue.async {
            let success = self.performWrite(request, action: "delete", table: table)
            DispatchQueue.main.async {
                completion?(success)
            }
        }
    }

    private func makeRequest(
        method: String,
        table: String,
        filters: [SupabaseFilter],
        onConflict: String?
    ) -> URLRequest? {
        guard let config = SupabaseConfiguration.current else { return nil }

        var components = URLComponents(
            url: config.url.appendingPathComponent("rest/v1/\(table)"),
            resolvingAgainstBaseURL: false
        )

        var queryItems = [URLQueryItem(name: "select", value: "*")]
        queryItems.append(contentsOf: filters.map { $0.asQueryItem() })
        if let onConflict {
            queryItems.append(URLQueryItem(name: "on_conflict", value: onConflict))
        }
        components?.queryItems = queryItems

        guard let url = components?.url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(config.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(config.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(config.schema, forHTTPHeaderField: "Accept-Profile")
        request.setValue(config.schema, forHTTPHeaderField: "Content-Profile")

        if method == "POST" {
            request.setValue("return=minimal,resolution=merge-duplicates", forHTTPHeaderField: "Prefer")
        }

        return request
    }

    private func makeRequest<T: Encodable>(
        method: String,
        table: String,
        filters: [SupabaseFilter],
        onConflict: String? = nil,
        body: T
    ) -> URLRequest? {
        guard var request = makeRequest(method: method, table: table, filters: filters, onConflict: onConflict) else {
            return nil
        }
        request.httpBody = try? encoder.encode(body)
        return request
    }

    private func performWrite(_ request: URLRequest, action: String, table: String) -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        var requestSuccess = false

        session.dataTask(with: request) { data, response, error in
            if let error {
                print("Supabase \(action) error:", error.localizedDescription)
            }
            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                print("Supabase \(action) failed:", table, "status:", http.statusCode)
                if let data, let body = String(data: data, encoding: .utf8) {
                    print("Supabase \(action) body:", body)
                }
            }

            requestSuccess = error == nil && (response as? HTTPURLResponse).map { 200..<300 ~= $0.statusCode } == true
            semaphore.signal()
        }.resume()

        semaphore.wait()
        return requestSuccess
    }
}
