//
//  LibraryView.swift
//  SOS
//
//  Created by Apple 12 on 18/07/25.
//

import SwiftUI

struct LibraryView: View {
    @StateObject private var libraryManager = LibraryManager()
    @State private var selectedTab = 0
    @State private var showingFilterMenu = false
    @State private var selectedFilter = "All"
    
    let filterOptions = ["All", "Recently Added", "A-Z", "Duration"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Tab Selector
                tabSelector
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    // Liked Videos Tab
                    likedVideosView
                        .tag(0)
                    
                    // Watch Later Tab
                    watchLaterView
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingFilterMenu = true
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 18))
                    }
                }
            }
            .sheet(isPresented: $showingFilterMenu) {
                filterMenuSheet
            }
        }
        .onAppear {
            loadLibraryData()
        }
    }
    
    // MARK: - UI Components
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(0..<2) { index in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: index == 0 ? "heart.fill" : "clock.fill")
                                .font(.system(size: 16))
                                .foregroundColor(selectedTab == index ? (index == 0 ? .red : .orange) : .secondary)
                            
                            Text(index == 0 ? "Liked" : "Watch Later")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(selectedTab == index ? .primary : .secondary)
                            
                            // Count badge
                            if (index == 0 ? libraryManager.likedPodcasts.count : libraryManager.watchLaterPodcasts.count) > 0 {
                                Text("\(index == 0 ? libraryManager.likedPodcasts.count : libraryManager.watchLaterPodcasts.count)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(index == 0 ? Color.red : Color.orange)
                                    )
                            }
                        }
                        
                        // Active indicator
                        Rectangle()
                            .fill(selectedTab == index ? (index == 0 ? Color.red : Color.orange) : Color.clear)
                            .frame(height: 2)
                            .animation(.easeInOut(duration: 0.3), value: selectedTab)
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .background(Color(.systemBackground))
        .overlay(
            Divider()
                .background(Color(.systemGray4)),
            alignment: .bottom
        )
    }
    
    private var likedVideosView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if libraryManager.likedPodcasts.isEmpty {
                    if libraryManager.isLoading {
                        ProgressView("Loading liked videos...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 100)
                    } else {
                        emptyStateView(
                            icon: "heart",
                            title: "No Liked Videos",
                            subtitle: "Videos you like will appear here"
                        )
                    }
                } else {
                    ForEach(filteredLikedPodcasts, id: \.id) { podcast in
                        NavigationLink(destination: VideoPlayerScreen(podcast: podcast, allPodcasts: libraryManager.allPodcasts)) {
                            libraryItemView(podcast: podcast, isLiked: true)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .refreshable {
            await refreshLikedVideos()
        }
    }
    
    private var watchLaterView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if libraryManager.watchLaterPodcasts.isEmpty {
                    if libraryManager.isLoading {
                        ProgressView("Loading watch later videos...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 100)
                    } else {
                        emptyStateView(
                            icon: "clock",
                            title: "No Videos to Watch Later",
                            subtitle: "Save videos to watch them later"
                        )
                    }
                } else {
                    ForEach(filteredWatchLaterPodcasts, id: \.id) { podcast in
                        NavigationLink(destination: VideoPlayerScreen(podcast: podcast, allPodcasts: libraryManager.allPodcasts)) {
                            libraryItemView(podcast: podcast, isWatchLater: true)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .refreshable {
            await refreshWatchLaterVideos()
        }
    }
    
    private func emptyStateView(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                // Navigate to discover/home
            }) {
                Text("Discover Videos")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.purple)
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
    
    private func libraryItemView(podcast: Podcast, isLiked: Bool = false, isWatchLater: Bool = false) -> some View {
        HStack(spacing: 12) {
            // Thumbnail with progress indicator
            ZStack(alignment: .bottomLeading) {
                // FIXED: Use thumbnail_url instead of stream_url for image display
                AsyncImage(url: URL(string: podcast.thumbnail_url ?? "")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else if phase.error != nil {
                        Rectangle()
                            .fill(Color(.systemGray4))
                            .overlay(
                                VStack(spacing: 4) {
                                    Image(systemName: "play.rectangle.fill")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                    Text("No Image")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            )
                    } else {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .overlay(
                                ProgressView()
                                    .tint(.gray)
                            )
                    }
                }
                .frame(width: 120, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Play button overlay
                Circle()
                    .fill(Color.black.opacity(0.6))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "play.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                    )
                    .offset(x: 8, y: -8)
                
                // Progress bar (placeholder)
                Rectangle()
                    .fill(Color.red)
                    .frame(height: 3)
                    .frame(width: 40) // Placeholder progress
                    .clipShape(RoundedRectangle(cornerRadius: 1.5))
                    .offset(x: 8, y: -4)
            }
            
            // Content info
            VStack(alignment: .leading, spacing: 8) {
                Text(podcast.title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 8) {
                    Text(podcast.author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 3, height: 3)
                    
                    Text("2 days ago")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 12) {
                    // Duration
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("15 min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Status indicator
                    if isLiked {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                            Text("Liked")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    if isWatchLater {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text("Watch Later")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            
            Spacer()
            
            // More options button
            Button(action: {
                // Handle more options
            }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .padding(8)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    private var filterMenuSheet: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter options
                VStack(spacing: 0) {
                    ForEach(filterOptions, id: \.self) { option in
                        Button(action: {
                            selectedFilter = option
                            showingFilterMenu = false
                        }) {
                            HStack {
                                Text(option)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if option == selectedFilter {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.purple)
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 0)
                                .fill(option == selectedFilter ? Color.purple.opacity(0.1) : Color.clear)
                        )
                        
                        if option != filterOptions.last {
                            Divider()
                                .padding(.leading, 20)
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Sort By")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showingFilterMenu = false
                    }
                    .foregroundColor(.purple)
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Data Management
    
    private var filteredLikedPodcasts: [Podcast] {
        return libraryManager.likedPodcasts.sorted { first, second in
            switch selectedFilter {
            case "Recently Added":
                return first.id > second.id // Assuming higher ID means more recent
            case "A-Z":
                return first.title < second.title
            case "Duration":
                return first.title < second.title // Placeholder - would sort by actual duration
            default:
                return first.id > second.id
            }
        }
    }
    
    private var filteredWatchLaterPodcasts: [Podcast] {
        return libraryManager.watchLaterPodcasts.sorted { first, second in
            switch selectedFilter {
            case "Recently Added":
                return first.id > second.id // Assuming higher ID means more recent
            case "A-Z":
                return first.title < second.title
            case "Duration":
                return first.title < second.title // Placeholder - would sort by actual duration
            default:
                return first.id > second.id
            }
        }
    }
    
    private func loadLibraryData() {
        libraryManager.loadLibraryData()
    }
    
    private func refreshLikedVideos() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        libraryManager.refreshLikedVideos()
    }
    
    private func refreshWatchLaterVideos() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        libraryManager.refreshWatchLaterVideos()
    }
}

// MARK: - Library Manager
class LibraryManager: ObservableObject {
    @Published var likedPodcasts: [Podcast] = []
    @Published var watchLaterPodcasts: [Podcast] = []
    @Published var allPodcasts: [Podcast] = []
    @Published var isLoading = false // Added loading state
    
    let supabaseUrl = "https://cpjokanmvsyvcnnysynk.supabase.co"
    let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNwam9rYW5tdnN5dmNubnlzeW5rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE2ODg3ODYsImV4cCI6MjA2NzI2NDc4Nn0.kr6EWyUjfrS1jTUMmb7csq9_x1FOCVjHulikEvZJUmU"
    let userId = UserDefaults.standard.string(forKey: "user_id") ?? ""
    
    func loadLibraryData() {
        isLoading = true
        fetchLibraryItems()
    }

    func refreshLikedVideos() {
        isLoading = true
        fetchLibraryItems()
    }

    func refreshWatchLaterVideos() {
        isLoading = true
        fetchLibraryItems()
    }

    private func fetchLibraryItems() {
        guard let url = URL(string: "\(supabaseUrl)/rest/v1/podcast_library?user_id=eq.\(userId)&select=podcast_id,is_liked,is_watch_later") else {
            DispatchQueue.main.async { self.isLoading = false }
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(UserDefaults.standard.string(forKey: "access_token") ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { self.isLoading = false }
            
            guard let data = data, error == nil else {
                print("❌ Failed to fetch library: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let entries = try JSONDecoder().decode([LibraryEntry].self, from: data)
                let likedIds = entries.filter { $0.is_liked }.map { $0.podcast_id }
                let watchLaterIds = entries.filter { $0.is_watch_later }.map { $0.podcast_id }
                
                
                self.fetchPodcasts(likedIds: likedIds, watchLaterIds: watchLaterIds)
            } catch {
                print("❌ JSON decode error: \(error)")
            }
        }.resume()
    }

    private func fetchPodcasts(likedIds: [Int], watchLaterIds: [Int]) {
        guard !likedIds.isEmpty || !watchLaterIds.isEmpty else {
            DispatchQueue.main.async {
                self.likedPodcasts = []
                self.watchLaterPodcasts = []
            }
            return
        }

        let allIds = Set(likedIds + watchLaterIds)
        let idList = allIds.map(String.init).joined(separator: ",")

        guard let url = URL(string: "\(supabaseUrl)/rest/v1/metadata?id=in.(\(idList))") else { return }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(UserDefaults.standard.string(forKey: "access_token") ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Failed to fetch podcast data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            
            do {
                let basePodcasts = try JSONDecoder().decode([Podcast].self, from: data)
                
                // IMPROVED: Better error handling and async processing
                let group = DispatchGroup()
                var enrichedPodcasts: [Podcast] = []
                let serialQueue = DispatchQueue(label: "podcast-processing")

                for podcast in basePodcasts {
                    group.enter()
                    self.fetchStreamAndThumbnail(for: podcast) { enriched in
                        serialQueue.async {
                            enrichedPodcasts.append(enriched)
                            group.leave()
                        }
                    }
                }

                group.notify(queue: .main) {
                    self.allPodcasts = enrichedPodcasts
                    
                    // Proper filtering
                    self.likedPodcasts = enrichedPodcasts.filter { likedIds.contains($0.id) }
                    self.watchLaterPodcasts = enrichedPodcasts.filter { watchLaterIds.contains($0.id) }
                    
                    print("✅ Liked podcasts count: \(self.likedPodcasts.count)")
                    print("✅ Watch Later podcasts count: \(self.watchLaterPodcasts.count)")
                    
                    // Debug: Print thumbnail URLs
                    for podcast in self.likedPodcasts {
                        print("🖼️ Podcast '\(podcast.title)' - Thumbnail: \(podcast.thumbnail_url ?? "nil")")
                    }
                }

            } catch {
                print("❌ Failed to decode podcasts: \(error)")
                print("📦 Raw data: \(String(data: data, encoding: .utf8) ?? "Invalid")")
            }
        }.resume()
    }
    
    private func fetchStreamAndThumbnail(for podcast: Podcast, completion: @escaping (Podcast) -> Void) {
        guard let youtubeURL = podcast.youtube_url,
              let encoded = youtubeURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let apiURL = URL(string: "http://127.0.0.1:5000/stream-url?url=\(encoded)") else {
            print("❌ Invalid YouTube URL for podcast: \(podcast.title)")
            completion(podcast)
            return
        }



        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 30.0 // Add timeout

        URLSession.shared.dataTask(with: request) { data, response, error in
            var updatedPodcast = podcast
            
            if let error = error {
                print("❌ Network error for \(podcast.title): \(error.localizedDescription)")
            } else if let data = data {
                do {
                    if let result = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        updatedPodcast.stream_url = result["stream_url"] as? String
                        updatedPodcast.thumbnail_url = result["thumbnail_url"] as? String
                        
                        print("✅ Got data for \(podcast.title):")
                        print("   Stream URL: \(updatedPodcast.stream_url ?? "nil")")
                        print("   Thumbnail URL: \(updatedPodcast.thumbnail_url ?? "nil")")
                    } else {
                        print("❌ Invalid JSON format for \(podcast.title)")
                    }
                } catch {
                    print("❌ JSON parsing error for \(podcast.title): \(error)")
                }
            }
            
            DispatchQueue.main.async {
                completion(updatedPodcast)
            }
        }.resume()
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
