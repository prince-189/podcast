import SwiftUI

struct HomeView: View {
    @State private var selectedCategory: String = "All"
    @State private var podcasts: [Podcast] = []
    @State private var selectedPodcast: Podcast?
    @State private var navigateToPlayer = false
    @State private var showingAddPodcast = false
    @State private var isLoading = false
    @State private var isRefreshing = false
    @State private var lastFetchedCategory: String = ""
    @State private var cachedPodcastsByCategory: [String: [Podcast]] = [:]
    @State private var currentOffset = 0
    @State private var canLoadMore = true

    let categories = ["All", "Technology", "Business", "Comedy", "Education", "News", "Health", "Sports", "Arts", "Science", "History", "Music", "True Crime", "Politics", "Religion", "Self-Help"]

    // Computed properties for different sections
    var featuredPodcasts: [Podcast] {
        // Show most recent podcasts as featured
        Array(podcasts.prefix(5))
    }
    
    var trendingPodcasts: [Podcast] {
        // Show podcasts from middle section as trending
        let startIndex = min(5, podcasts.count)
        let endIndex = min(startIndex + 3, podcasts.count)
        return Array(podcasts[startIndex..<endIndex])
    }
    
    var recentPodcasts: [Podcast] {
        // Show next batch as recent
        let startIndex = min(8, podcasts.count)
        let endIndex = min(startIndex + 6, podcasts.count)
        return Array(podcasts[startIndex..<endIndex])
    }
    
    var recommendedPodcasts: [Podcast] {
        // Show shuffled selection for recommendations
        let availablePodcasts = Array(podcasts.dropFirst(14))
        return Array(availablePodcasts.shuffled().prefix(4))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    // Category Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(categories, id: \.self) { category in
                                CategoryChip(
                                    title: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        selectedCategory = category
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    if isLoading && podcasts.isEmpty {
                        LoadingView()
                    } else if !podcasts.isEmpty {
                        // Featured Section
                        if !featuredPodcasts.isEmpty {
                            PodcastSection(
                                title: "Featured",
                                podcasts: featuredPodcasts,
                                displayStyle: .featured,
                                onPodcastTap: playPodcast
                            )
                        }

                        // Trending Section
                        if !trendingPodcasts.isEmpty {
                            PodcastSection(
                                title: "Trending Now",
                                podcasts: trendingPodcasts,
                                displayStyle: .trending,
                                onPodcastTap: playPodcast
                            )
                        }

                        // Recent Podcasts Section
                        if !recentPodcasts.isEmpty {
                            PodcastSection(
                                title: "Recent Episodes",
                                podcasts: recentPodcasts,
                                displayStyle: .recent,
                                onPodcastTap: playPodcast
                            )
                        }

                        // Recommended Section
                        if !recommendedPodcasts.isEmpty {
                            PodcastSection(
                                title: "Recommended for You",
                                podcasts: recommendedPodcasts,
                                displayStyle: .recommended,
                                onPodcastTap: playPodcast
                            )
                        }
                        
                        // Load More Button
                        if canLoadMore && !isLoading {
                            LoadMoreButton {
                                loadMorePodcasts()
                            }
                        }
                        
                        // Manual Refresh Button
                        RefreshButton(isRefreshing: isRefreshing) {
                            refreshData()
                        }
                    }
                    
                    Spacer(minLength: 100) // Space for floating button
                }
                .padding(.top)
                
                if let selected = selectedPodcast {
                    NavigationLink(
                        destination: VideoPlayerScreen(podcast: selected, allPodcasts: podcasts),
                        isActive: $navigateToPlayer,
                        label: { EmptyView() }
                    )
                    .hidden()
                }
            }
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddPodcast) {
                AddPodcastView()
            }
            .onAppear {
                if podcasts.isEmpty {
                    fetchPodcasts(reset: true)
                }
            }
            .onChange(of: selectedCategory) { newCategory in
                handleCategoryChange(newCategory)
            }
        }
        .overlay(
            FloatingAddButton {
                showingAddPodcast = true
            }
        )
    }

    // MARK: - Data Loading Methods
    
    func handleCategoryChange(_ newCategory: String) {
        // Check if we have cached data for this category
        if let cachedPodcasts = cachedPodcastsByCategory[newCategory] {
            withAnimation(.easeInOut(duration: 0.3)) {
                podcasts = cachedPodcasts
                currentOffset = 0
                canLoadMore = cachedPodcasts.count >= 20
            }
        } else {
            // Only fetch if not cached
            fetchPodcasts(reset: true)
        }
    }
    
    func refreshData() {
        isRefreshing = true
        // Clear cache for current category to force fresh data
        cachedPodcastsByCategory[selectedCategory] = nil
        fetchPodcasts(reset: true)
    }
    
    func loadMorePodcasts() {
        guard !isLoading else { return }
        fetchPodcasts(reset: false)
    }

    func fetchPodcasts(reset: Bool) {
        if reset {
            currentOffset = 0
            canLoadMore = true
        }
        
        guard canLoadMore else { return }
        
        isLoading = true
        
        let supabaseUrl = "https://cpjokanmvsyvcnnysynk.supabase.co"
        let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNwam9rYW5tdnN5dmNubnlzeW5rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE2ODg3ODYsImV4cCI6MjA2NzI2NDc4Nn0.kr6EWyUjfrS1jTUMmb7csq9_x1FOCVjHulikEvZJUmU"

        let limit = 20
        var urlString = "\(supabaseUrl)/rest/v1/metadata?select=*&order=created_at.desc&limit=\(limit)&offset=\(currentOffset)"
        
        if selectedCategory != "All" {
            let encoded = selectedCategory.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            urlString += "&category=eq.\(encoded)"
        }

        guard let url = URL(string: urlString) else {
            isLoading = false
            isRefreshing = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(supabaseAnonKey, forHTTPHeaderField: "apikey")

        if let accessToken = UserDefaults.standard.string(forKey: "access_token") {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            print("🔒 Missing access token — user not authenticated.")
            isLoading = false
            isRefreshing = false
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                isRefreshing = false
            }
            
            if let error = error {
                print("❌ Error fetching podcasts:", error.localizedDescription)
                return
            }

            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode([Podcast].self, from: data)
                DispatchQueue.main.async {
                    if reset {
                        podcasts = decoded
                    } else {
                        podcasts.append(contentsOf: decoded)
                    }
                    
                    // Cache the data
                    cachedPodcastsByCategory[selectedCategory] = podcasts
                    
                    // Update pagination
                    currentOffset += limit
                    canLoadMore = decoded.count == limit
                    
                    // Fetch stream data for new podcasts
                    let podcastsToProcess = reset ? decoded : decoded
                    for podcast in podcastsToProcess {
                        fetchStreamData(for: podcast) { stream, thumbnail in
                            DispatchQueue.main.async {
                                if let index = podcasts.firstIndex(where: { $0.id == podcast.id }) {
                                    podcasts[index].stream_url = stream
                                    podcasts[index].thumbnail_url = thumbnail
                                    // Update cache
                                    cachedPodcastsByCategory[selectedCategory] = podcasts
                                }
                            }
                        }
                    }
                }
            } catch {
                print("❌ Decoding error:", error)
            }
        }.resume()
    }

    func playPodcast(_ podcast: Podcast) {
        selectedPodcast = podcast
        navigateToPlayer = true
    }
}

// MARK: - UI Components

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.purple : Color.gray.opacity(0.15))
                )
                .foregroundColor(isSelected ? .white : .primary)
                .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PodcastSection: View {
    let title: String
    let podcasts: [Podcast]
    let displayStyle: SectionStyle
    let onPodcastTap: (Podcast) -> Void
    
    enum SectionStyle {
        case featured, trending, recent, recommended
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal)
            
            switch displayStyle {
            case .featured:
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(podcasts) { podcast in
                            FeaturedPodcastCard(podcast: podcast)
                                .onTapGesture { onPodcastTap(podcast) }
                        }
                    }
                    .padding(.horizontal)
                }
                
            case .trending:
                VStack(spacing: 12) {
                    ForEach(podcasts) { podcast in
                        TrendingPodcastRow(podcast: podcast)
                            .onTapGesture { onPodcastTap(podcast) }
                    }
                }
                .padding(.horizontal)
                
            case .recent:
                LazyVStack(spacing: 12) {
                    ForEach(podcasts) { podcast in
                        EpisodeRowView(podcast: podcast)
                            .onTapGesture { onPodcastTap(podcast) }
                    }
                }
                .padding(.horizontal)
                
            case .recommended:
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(podcasts) { podcast in
                            RecommendedPodcastCard(podcast: podcast)
                                .onTapGesture { onPodcastTap(podcast) }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading podcasts...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct RefreshButton: View {
    let isRefreshing: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isRefreshing {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "arrow.clockwise")
                }
                Text(isRefreshing ? "Refreshing..." : "Refresh")
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.purple)
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.purple, lineWidth: 1.5)
                    .background(Color.purple.opacity(0.05))
            )
        }
        .disabled(isRefreshing)
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

struct LoadMoreButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "arrow.down.circle")
                Text("Load More")
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.purple)
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.purple, lineWidth: 1.5)
            )
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

struct FloatingAddButton: View {
    let action: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: action) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.purple, Color.purple.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .scaleEffect(1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: true)
                .padding(.trailing, 24)
                .padding(.bottom, 24)
            }
        }
    }
}



// MARK: - Enhanced UI Components

struct FeaturedPodcastCard: View {
    let podcast: Podcast
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsyncImage(url: URL(string: podcast.thumbnail_url ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else if phase.error != nil {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(podcast.color.opacity(0.3))
                        .overlay(
                            Image(systemName: "podcast")
                                .font(.title)
                                .foregroundColor(podcast.color)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(ProgressView())
                }
            }
            .frame(width: 240, height: 150)
            .clipped()
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(podcast.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text(podcast.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(width: 240)
        .padding(.vertical, 4)
    }
}

struct TrendingPodcastRow: View {
    let podcast: Podcast
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: podcast.thumbnail_url ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else if phase.error != nil {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(podcast.color.opacity(0.3))
                        .overlay(
                            Image(systemName: "podcast")
                                .foregroundColor(podcast.color)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(ProgressView().scaleEffect(0.8))
                }
            }
            .frame(width: 70, height: 70)
            .clipped()
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(podcast.title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text(podcast.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "play.circle.fill")
                .font(.title2)
                .foregroundColor(.purple)
        }
        .padding(.vertical, 4)
    }
}

struct EpisodeRowView: View {
    let podcast: Podcast
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: podcast.thumbnail_url ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else if phase.error != nil {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(podcast.color.opacity(0.3))
                        .overlay(
                            Image(systemName: "podcast")
                                .font(.caption)
                                .foregroundColor(podcast.color)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(ProgressView().scaleEffect(0.7))
                }
            }
            .frame(width: 60, height: 60)
            .clipped()
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 2) {
                Text(podcast.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(podcast.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

struct RecommendedPodcastCard: View {
    let podcast: Podcast
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: podcast.thumbnail_url ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else if phase.error != nil {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(podcast.color.opacity(0.3))
                        .overlay(
                            Image(systemName: "podcast")
                                .font(.title2)
                                .foregroundColor(podcast.color)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(ProgressView())
                }
            }
            .frame(width: 160, height: 120)
            .clipped()
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 2) {
                Text(podcast.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text(podcast.author)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(width: 160)
    }
}

// MARK: - Podcast Model and Extensions

struct Podcast: Identifiable, Decodable {
    let id: Int
    let title: String
    let author: String
    let description: String
    let youtube_url: String?
    let language: String?
    var stream_url: String?
    var thumbnail_url: String?
    let color: Color

    enum CodingKeys: String, CodingKey {
        case id, title, author, description, youtube_url, language
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        author = try container.decode(String.self, forKey: .author)
        description = try container.decode(String.self, forKey: .description)
        youtube_url = try? container.decodeIfPresent(String.self, forKey: .youtube_url)
        language = try? container.decodeIfPresent(String.self, forKey: .language)
        stream_url = nil
        thumbnail_url = nil
        color = .random()
    }
}

extension Color {
    static func random() -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .mint, .pink, .teal, .indigo]
        return colors.randomElement() ?? .gray
    }
}

// MARK: - Stream Data Fetching

func fetchStreamData(for podcast: Podcast, completion: @escaping (String?, String?) -> Void) {
    guard let ytUrl = podcast.youtube_url else {
        completion(nil, nil)
        return
    }

    let base = "http://127.0.0.1:5000/stream-url"
    guard let encoded = ytUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let url = URL(string: "\(base)?url=\(encoded)") else {
        completion(nil, nil)
        return
    }

    URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data, error == nil else {
            completion(nil, nil)
            return
        }

        if let result = try? JSONDecoder().decode(StreamResponse.self, from: data) {
            completion(result.stream_url, result.thumbnail_url)
        } else {
            completion(nil, nil)
        }
    }.resume()
}

struct StreamResponse: Decodable {
    let stream_url: String
    let thumbnail_url: String
}
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
