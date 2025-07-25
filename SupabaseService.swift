

import Foundation

struct SupabaseUser: Codable {
    let id: String
    let email: String
}

enum SupabaseAuthError: Error {
    case invalidResponse
    case custom(String)
    case decodingError(Error)
}

class SupabaseAuthService {
    static let shared = SupabaseAuthService()
    
    let supabaseUrl = "https://cpjokanmvsyvcnnysynk.supabase.co"
    let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNwam9rYW5tdnN5dmNubnlzeW5rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE2ODg3ODYsImV4cCI6MjA2NzI2NDc4Nn0.kr6EWyUjfrS1jTUMmb7csq9_x1FOCVjHulikEvZJUmU"
    
    func signUp(email: String, password: String, username: String, completion: @escaping (Result<[String: Any], SupabaseAuthError>) -> Void) {
        guard let url = URL(string: "\(supabaseUrl)/auth/v1/signup") else {
            completion(.failure(.custom("Invalid URL")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "data": [
                "display_name": username
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.custom(error.localizedDescription)))
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                completion(.failure(.invalidResponse))
                return
            }
            
            completion(.success(json))
        }.resume()
    }
    
    
    func signIn(email: String, password: String, completion: @escaping (Result<[String: Any], SupabaseAuthError>) -> Void) {
        guard let url = URL(string: "\(supabaseUrl)/auth/v1/token?grant_type=password") else {
            completion(.failure(.custom("Invalid URL")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(.custom(error.localizedDescription)))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.custom(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            // Print response for debugging
            print("Status code: \(httpResponse.statusCode)")
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response data: \(responseString)")
            }
            
            if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300, let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        // Save access/refresh tokens (optional, based on your app logic)
                        if let accessToken = json["access_token"] as? String {
                            UserDefaults.standard.set(accessToken, forKey: "access_token")
                        }
                        if let refreshToken = json["refresh_token"] as? String {
                            UserDefaults.standard.set(refreshToken, forKey: "refresh_token")
                        }
                        if let user = json["user"] as? [String: Any],
                           let userID = user["id"] as? String {
                            UserDefaults.standard.setValue(userID, forKey: "user_id")
                        }
                        
                        completion(.success(json))
                    } else {
                        completion(.failure(.custom("Invalid JSON response format")))
                    }
                } catch let error {
                    completion(.failure(.decodingError(error)))
                }
            }
            else {
                var errorMessage = "Server error: \(httpResponse.statusCode)"
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            if let message = json["message"] as? String {
                                errorMessage = message
                            } else if let error = json["error"] as? String {
                                errorMessage = error
                            } else if let error = json["error_description"] as? String {
                                errorMessage = error
                            }
                        }
                    } catch {
                        print("Error parsing error response: \(error)")
                    }
                }
                completion(.failure(.custom(errorMessage)))
            }
        }.resume()
    }
}
