//  AddPodcastView.swift
//  SOS
//
//  Created by Apple 12 on 15/07/25.

import SwiftUI

struct AddPodcastView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var description = ""
    @State private var author = ""
    @State private var category = "Technology"
    @State private var youtubeURL = ""
    @State private var tags = ""
    @State private var language = "English"
    @State private var duration = ""
    @State private var isExplicit = false
    @State private var website = ""
    @State private var rssURL = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSubmitting = false

    let categories = ["Technology", "Business", "Comedy", "Education", "News", "Health", "Sports", "Arts", "Science", "History", "Music", "True Crime", "Politics", "Religion", "Self-Help"]
    let languages = ["English", "Spanish", "French", "German", "Italian", "Portuguese", "Japanese", "Korean", "Chinese", "Hindi", "Arabic", "Russian"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    basicInfoSection
                    contentDetailsSection
                    additionalInfoSection
                    submitButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
                .gesture(
                    TapGesture()
                        .onEnded {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                )

            }
            .scrollDismissesKeyboard(.interactively)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationTitle("Add Podcast")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.purple)
            Text("Share Your Podcast")
                .font(.title2)
                .fontWeight(.bold)
            Text("Fill in the details below to add your podcast to our platform")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Basic Information")

            VStack(alignment: .leading, spacing: 8) {
                Text("Podcast Title *").font(.subheadline).fontWeight(.medium)
                TextField("Enter podcast title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Author/Host *").font(.subheadline).fontWeight(.medium)
                TextField("Enter author or host name", text: $author)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Description *").font(.subheadline).fontWeight(.medium)
                TextEditor(text: $description)
                    .textSelection(.enabled)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray4), lineWidth: 1))
            }
        }
    }

    private var contentDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Content Details")

            VStack(alignment: .leading, spacing: 8) {
                Text("Category *").font(.subheadline).fontWeight(.medium)
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { Text($0) }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("YouTube URL *").font(.subheadline).fontWeight(.medium)
                TextField("https://youtube.com/watch?v=...", text: $youtubeURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.URL)
                    .autocapitalization(.none)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Duration *").font(.subheadline).fontWeight(.medium)
                TextField("e.g., 45 min or 1h 30min", text: $duration)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Language *").font(.subheadline).fontWeight(.medium)
                Picker("Language", selection: $language) {
                    ForEach(languages, id: \.self) { Text($0) }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Tags").font(.subheadline).fontWeight(.medium)
                TextField("Enter tags separated by commas", text: $tags)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text("Help listeners discover your podcast with relevant tags")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var additionalInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("Additional Information")

            VStack(alignment: .leading, spacing: 8) {
                Text("Website").font(.subheadline).fontWeight(.medium)
                TextField("https://yourpodcast.com", text: $website)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.URL)
                    .autocapitalization(.none)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("RSS Feed URL").font(.subheadline).fontWeight(.medium)
                TextField("https://feeds.example.com/podcast.rss", text: $rssURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.URL)
                    .autocapitalization(.none)
            }

            Toggle("Explicit Content", isOn: $isExplicit)
                .font(.subheadline).fontWeight(.medium)
            Text("Mark this if your podcast contains explicit language or mature themes")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var submitButton: some View {
        VStack(spacing: 16) {
            Button(action: submitPodcastAction) {
                if isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                } else {
                    Text("Submit Podcast")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            }
            .background(Color.purple)
            .cornerRadius(12)
            .disabled(!isFormValid || isSubmitting)
            .opacity((!isFormValid || isSubmitting) ? 0.6 : 1.0)

            Text("* Required fields")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.top, 8)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
    }

    private var isFormValid: Bool {
        !title.isEmpty &&
        !author.isEmpty &&
        !description.isEmpty &&
        !youtubeURL.isEmpty &&
        !duration.isEmpty &&
        isValidYouTubeURL(youtubeURL)
    }

    private func isValidYouTubeURL(_ url: String) -> Bool {
        url.contains("youtube.com") || url.contains("youtu.be")
    }

    private func submitPodcastAction() {
        guard isFormValid else {
            alertMessage = "Please fill in all required fields."
            showingAlert = true
            return
        }

        isSubmitting = true

        submitPodcast(
            title: title,
            author: author,
            description: description,
            youtubeURL: youtubeURL,
            duration: duration,
            category: category,
            isExplicit: isExplicit,
            language: language,
            tags: tags,
            website: website,
            rssURL: rssURL
        ) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success:
                    alertMessage = "Podcast submitted successfully!"
                    showingAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        presentationMode.wrappedValue.dismiss()
                    }
                case .failure(let error):
                    switch error {
                    case .custom(let msg): alertMessage = msg
                    case .invalidURL: alertMessage = "Invalid Supabase URL"
                    case .invalidResponse: alertMessage = "Server returned an invalid response"
                    case .decodingError(let e): alertMessage = "Decoding error: \(e.localizedDescription)"
                    }
                    showingAlert = true
                }
            }
        }
    }
}


let supabaseUrl = "https://cpjokanmvsyvcnnysynk.supabase.co"
let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNwam9rYW5tdnN5dmNubnlzeW5rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE2ODg3ODYsImV4cCI6MjA2NzI2NDc4Nn0.kr6EWyUjfrS1jTUMmb7csq9_x1FOCVjHulikEvZJUmU"
// MARK:-function to insert
enum SupabaseSubmissionError: Error {
    case invalidURL
    case custom(String)
    case invalidResponse
    case decodingError(Error)
}

func submitPodcast(
    title: String,
    author: String,
    description: String,
    youtubeURL: String,
    duration: String,
    category: String,
    isExplicit: Bool,
    language: String,
    tags: String,
    website: String,
    rssURL: String,
    completion: @escaping (Result<[String: Any], SupabaseSubmissionError>) -> Void
) {
    guard let url = URL(string: "\(supabaseUrl)/rest/v1/metadata") else {
        completion(.failure(.invalidURL))
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
    if let accessToken = UserDefaults.standard.string(forKey: "access_token") {
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    } else {
        completion(.failure(.custom("Missing access token")))
        return
    }
    request.setValue("return=representation", forHTTPHeaderField: "Prefer")

    // Validate YouTube URL
    guard youtubeURL.contains("youtube.com") || youtubeURL.contains("youtu.be") else {
        completion(.failure(.custom("Invalid YouTube URL")))
        return
    }

    let body: [String: Any] = [
        "title": title,
        "author": author,
        "description": description,
        "youtube_url": youtubeURL,
        "duration": duration,
        "category": category,
        "is_explicit": isExplicit,
        "language": language,
        "tags": tags,
        "website": website,
        "rss_url": rssURL
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

        if let data = data, let responseString = String(data: data, encoding: .utf8) {
            print("Status code: \(httpResponse.statusCode)")
            print("Response: \(responseString)")
        }

        if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300, let data = data {
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    completion(.success(json))
                } else {
                    completion(.failure(.custom("Invalid JSON response format")))
                }
            } catch let error {
                completion(.failure(.decodingError(error)))
            }
        } else {
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


struct AddPodcastView_Previews: PreviewProvider {
    static var previews: some View {
        AddPodcastView()
    }
}
