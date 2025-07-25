//import Foundation
//
//// MARK: - Models
//struct SupabaseUser: Codable {
//    let id: String
//    let email: String?
//    let phone: String?
//    let app_metadata: [String: String]?
//    let user_metadata: [String: String]?
//    let aud: String?
//    let created_at: String?
//}
//
//struct AuthError: Codable {
//    let message: String
//    let status: Int?
//}
//
//struct AuthResponse: Codable {
//    let access_token: String?
//    let refresh_token: String?
//    let user: SupabaseUser?
//    let error: String?
//    let error_description: String?
//
//    // Add CodingKeys to handle potential mismatches
//    enum CodingKeys: String, CodingKey {
//        case access_token, refresh_token, user, error, error_description
//    }
//}
//
//enum SupabaseAuthError: Error {
//    case message(String)
//    case networkError(Error)
//    case serverError(Int, String)
//    case decodingError(Error)
//}
//
//// MARK: - Configuration
//struct SupabaseConfig {
//    static let baseURL = "https://cpjokanmvsyvcnnysynk.supabase.co"
//    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNwam9rYW5tdnN5dmNubnlzeW5rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE2ODg3ODYsImV4cCI6MjA2NzI2NDc4Nn0.kr6EWyUjfrS1jTUMmb7csq9_x1FOCVjHulikEvZJUmU" // Replace with your actual anon key
//}
//
//// MARK: - Auth Service
//class SupabaseAuthService {
//    static let shared = SupabaseAuthService()
//
//    private init() {}
//
//    // MARK: - Sign Up
//    func signUp(email: String, password: String, username: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
//        guard let url = URL(string: "\(SupabaseConfig.baseURL)/auth/v1/signup") else {
//            completion(.failure(NSError(domain: "SupabaseAuth", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("\(SupabaseConfig.anonKey)", forHTTPHeaderField: "apikey")
//
//        let body: [String: Any] = [
//            "email": email,
//            "password": password,
//            "data": [
//                "username": username,
//                "display_name": username
//            ]
//        ]
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: body)
//        } catch {
//            completion(.failure(error))
//            return
//        }
//
//        // Optional debugging
//        #if DEBUG
//        print("Signup URL: \(url)")
//        print("Signup headers: \(request.allHTTPHeaderFields ?? [:])")
//        if let bodyData = request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
//            print("Signup body: \(bodyString)")
//        }
//        #endif
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            // Handle network error
//            if let error = error {
//                DispatchQueue.main.async { completion(.failure(error)) }
//                return
//            }
//
//            // Validate HTTP response
//            guard let httpResponse = response as? HTTPURLResponse else {
//                DispatchQueue.main.async {
//                    completion(.failure(NSError(domain: "SupabaseAuth", code: 0,
//                                               userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
//                }
//                return
//            }
//
//            #if DEBUG
//            print("Signup status code: \(httpResponse.statusCode)")
//            if let data = data, let responseString = String(data: data, encoding: .utf8) {
//                print("Signup response: \(responseString)")
//            }
//            #endif
//
//            // Process response based on status code
//            DispatchQueue.main.async {
//                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300, let data = data {
//                    do {
//                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
//                            completion(.success(json))
//                        } else {
//                            completion(.failure(NSError(domain: "SupabaseAuth", code: 0,
//                                                      userInfo: [NSLocalizedDescriptionKey: "Invalid JSON response"])))
//                        }
//                    } catch {
//                        completion(.failure(error))
//                    }
//                } else {
//                    // Extract error message if available
//                    var errorMessage = "Server error: \(httpResponse.statusCode)"
//                    if let data = data,
//                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//                       let message = json["message"] as? String {
//                        errorMessage = message
//                    }
//                    completion(.failure(NSError(domain: "SupabaseAuth", code: httpResponse.statusCode,
//                                              userInfo: [NSLocalizedDescriptionKey: errorMessage])))
//                }
//            }
//        }.resume()
//    }
//
//    // MARK: - Sign In
//    func signIn(email: String, password: String, completion: @escaping (Result<SupabaseUser, SupabaseAuthError>) -> Void) {
//        guard let url = URL(string: "\(SupabaseConfig.baseURL)/auth/v1/token?grant_type=password") else {
//            completion(.failure(.message("Invalid URL")))
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        // Headers
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("\(SupabaseConfig.anonKey)", forHTTPHeaderField: "apikey")
//        request.setValue("Bearer \(SupabaseConfig.anonKey)", forHTTPHeaderField: "Authorization")
//
//        // Body
//        let body: [String: Any] = [
//            "email": email,
//            "password": password
//        ]
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: body)
//        } catch {
//            completion(.failure(.message("Failed to encode request body")))
//            return
//        }
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            // Similar error handling as signUp method
//            // ...
//
//            // Parse successful response
//            do {
//                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data!)
//
//                if let user = authResponse.user {
//                    DispatchQueue.main.async {
//                        completion(.success(user))
//                    }
//                } else {
//                    DispatchQueue.main.async {
//                        completion(.failure(.message("User data missing in response")))
//                    }
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    completion(.failure(.decodingError(error)))
//                }
//            }
//        }.resume()
//    }
//
//}
// SupabaseAuthService.swift
