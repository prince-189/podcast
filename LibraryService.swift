import Foundation

enum LibraryError: Error {
    case invalidURL
    case networkError(String)
    case decodingError(Error)
    case serverError(statusCode: Int)
}

struct LibraryEntry: Codable {
    let podcast_id: Int
    let user_id: String?
    let is_liked: Bool
    let is_watch_later: Bool
}

class LibraryService {
    static let shared = LibraryService()
    private init() {}

    let supabaseUrl = "https://cpjokanmvsyvcnnysynk.supabase.co"
    let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNwam9rYW5tdnN5dmNubnlzeW5rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE2ODg3ODYsImV4cCI6MjA2NzI2NDc4Nn0.kr6EWyUjfrS1jTUMmb7csq9_x1FOCVjHulikEvZJUmU"

    func updateLibrary(podcastId: Int, userId: String, isLiked: Bool?, isWatchLater: Bool?, completion: @escaping (Result<(isLiked: Bool, isWatchLater: Bool), LibraryError>) -> Void) {
        guard let url = URL(string: "\(supabaseUrl)/rest/v1/rpc/upsert_podcast_library") else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("return=representation", forHTTPHeaderField: "Prefer")

        if let accessToken = UserDefaults.standard.string(forKey: "access_token") {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            print("🔒 Missing access token — user not authenticated.")
            completion(.failure(.networkError("No access token")))
            return
        }

        // Prepare the request body
        let body: [String: Any?] = [
            "p_podcast_id": podcastId,
            "p_user_id": userId,
            "p_is_liked": isLiked,
            "p_is_watch_later": isWatchLater
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(.networkError("JSON encoding failed: \(error.localizedDescription)")))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError("Network error: \(error.localizedDescription)")))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.networkError("No response from server")))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                return
            }

            // Parse the returned data
            guard let data = data else {
                completion(.failure(.networkError("No data received")))
                return
            }

            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Bool]],
                   let result = jsonResult.first {
                    let isLiked = result["result_is_liked"] ?? false
                    let isWatchLater = result["result_is_watch_later"] ?? false
                    completion(.success((isLiked: isLiked, isWatchLater: isWatchLater)))
                } else {
                    completion(.failure(.decodingError(NSError(domain: "LibraryService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"]))))
                }
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
}
