//import Foundation
//import SwiftUI
//
//struct AudioMetadata: Identifiable, Codable {
//    let id: Int
//    let title: String
//    let author: String
//    let description: String
//    let type: String
//    let categories: [String]
//    let audio_url: String
//    let cover_url: String
//    let user_id: String
//    let created_at: String
//    let updated_at: String
//    let language: String
//    
//    enum CodingKeys: String, CodingKey {
//        case id, title, author, description, type, categories, audio_url, cover_url
//        case user_id, created_at, updated_at, language
//    }
//}
//
//class HomeViewModel: ObservableObject {
//    @Published var categoryItems: [AudioMetadata] = []
//    @Published var selectedCategory: String = "All"
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    
//    private let supabaseUrl = "https://cpjokanmvsyvcnnysynk.supabase.co/rest/v1/audio_metadata"
//    private let apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNwam9rYW5tdnN5dmNubnlzeW5rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE2ODg3ODYsImV4cCI6MjA2NzI2NDc4Nn0.kr6EWyUjfrS1jTUMmb7csq9_x1FOCVjHulikEvZJUmU"
//    private let authToken=UserDefaults.standard.string(forKey: "access_token")
//    func fetchByCategory(category: String) async {
//        await MainActor.run {
//            isLoading = true
//            errorMessage = nil
//        }
//        
//        // Construct the URL with proper encoding
//        var urlComponents = URLComponents(string: supabaseUrl)
//        var queryItems = [URLQueryItem]()
//        
//        // Always add the select parameter to get all fields
//        queryItems.append(URLQueryItem(name: "select", value: "*"))
//        
//        // Add query parameters based on category
//        if category != "All" {
//            // For PostgreSQL: WHERE 'category' = ANY(categories)
//            let encodedValue = "cs.{\"\(category)\"}"
//            queryItems.append(URLQueryItem(name: "categories", value: encodedValue))
//        }
//        
//        urlComponents?.queryItems = queryItems
//        
//        guard let url = urlComponents?.url else {
//            await MainActor.run {
//                errorMessage = "Invalid URL"
//                isLoading = false
//            }
//            return
//        }
//        
//        print("Request URL: \(url.absoluteString)")
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
//        request.setValue(apiKey, forHTTPHeaderField: "apikey")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(authToken ?? "")",forHTTPHeaderField:"Authorization")
//        request.setValue("*/*", forHTTPHeaderField: "Accept")
//        
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//            
//            // Debug: Print the response
//            if let httpResponse = response as? HTTPURLResponse {
//                print("HTTP Status Code: \(httpResponse.statusCode)")
//                print("Response Headers: \(httpResponse.allHeaderFields)")
//            }
//            
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("Response JSON: \(jsonString)")
//            }
//            
//            // Decode the response
//            let items = try JSONDecoder().decode([AudioMetadata].self, from: data)
//            
//            await MainActor.run {
//                self.categoryItems = items
//                self.isLoading = false
//            }
//        } catch {
//            print("Failed to fetch or decode:", error)
//            
//            // Try to get more detailed error information
//            if let decodingError = error as? DecodingError {
//                switch decodingError {
//                case .typeMismatch(let type, let context):
//                    print("Type mismatch: Expected \(type), context: \(context)")
//                case .valueNotFound(let type, let context):
//                    print("Value not found: \(type), context: \(context)")
//                case .keyNotFound(let key, let context):
//                    print("Key not found: \(key), context: \(context)")
//                case .dataCorrupted(let context):
//                    print("Data corrupted: \(context)")
//                @unknown default:
//                    print("Unknown decoding error")
//                }
//            }
//            
//            await MainActor.run {
//                self.errorMessage = "Error: \(error.localizedDescription)"
//                self.isLoading = false
//            }
//        }
//    }
//    
//    // Function to fetch all items (when "All" is selected)
//    func fetchAllItems() async {
//        await fetchByCategory(category: "All")
//    }
//    
//    // Function to update the selected category and fetch items
//    func updateCategory(to newCategory: String) async {
//        selectedCategory = newCategory
//        await fetchByCategory(category: newCategory)
//    }
//}
