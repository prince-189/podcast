//
//  VideoPlayerScreen.swift
//  SOS
//
//  Created by Apple 12 on 16/07/25.
//

import SwiftUI
import AVKit

struct VideoPlayerScreen: View {
    let podcast: Podcast
    let allPodcasts: [Podcast]
    let userUID = UserDefaults.standard.string(forKey: "user_id") ?? ""
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var playbackRate: Float = 1.0
    @State private var isLoading = true
    @State private var showSpeedMenu = false
    @State private var isLiked = false
    @State private var isWatchLater = false
    @State private var showFullDescription = false
    @StateObject private var playerManager = PlayerManager()

    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Enhanced Player Section with Default Controls
                    ZStack {
                        if let player = player {
                            VideoPlayer(player: player)
                                .frame(height: min(geometry.size.height * 0.3, 250))
                                .onAppear {
                                    setupPlayer()
                                }
                        } else {
                            loadingView
                                .frame(height: min(geometry.size.height * 0.3, 250))
                        }
                    }
                    .background(Color.black)
                    
                    // Enhanced Action Bar
                    actionBar
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    
                    // Enhanced Podcast Information Section
                    podcastInfoSection
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    
                    // Enhanced Playback Controls
                    playbackControlsSection
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                        )
                        .padding(.horizontal, 16)
                    
                    // Enhanced Recommended Section
                    if !allPodcasts.isEmpty {
                        recommendedSection
                            .padding(.top, 24)
                    }
                }
            }
            .background(Color(.systemBackground))
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("Back")
                            .font(.system(size: 16))
                    }
                    .foregroundColor(.primary)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showSpeedMenu = true }) {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 18))
                        .foregroundColor(.primary)
                }
            }
        }
        .onDisappear {
            cleanup()
        }
        .onAppear {
            setupAudioSession()
            initializePlayer()
        }
        .sheet(isPresented: $showSpeedMenu) {
            speedMenuSheet
        }
    }
    
    // MARK: - UI Components
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.purple)
            
            Text("Loading video...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
    
    private var actionBar: some View {
        HStack(spacing: 24) {
            // Like Button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isLiked.toggle()
                }
                // Add haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                LibraryService.shared.updateLibrary(podcastId: podcast.id,
                                                    userId: userUID,
                                                    isLiked: true,
                                                    isWatchLater: nil) { result in
                        switch result {
                        case .success:
                            print("Like status updated")
                        case .failure(let error):
                            print("Error updating like status: \(error.localizedDescription)")
                        }
                    }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isLiked ? .red : .primary)
                        .scaleEffect(isLiked ? 1.2 : 1.0)
                    
                    Text(isLiked ? "Liked" : "Like")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isLiked ? .red : .primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isLiked ? Color.red.opacity(0.1) : Color(.systemGray5))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Watch Later Button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isWatchLater.toggle()
                }
                // Add haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                LibraryService.shared.updateLibrary(podcastId: podcast.id,
                                                    userId: userUID,
                                                    isLiked: nil,
                                                    isWatchLater: true) { result in
                       switch result {
                       case .success:
                           print("Watch Later updated")
                       case .failure(let error):
                           print("Error updating Watch Later: \(error.localizedDescription)")
                       }
                   }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: isWatchLater ? "clock.fill" : "clock")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isWatchLater ? .orange : .primary)
                        .scaleEffect(isWatchLater ? 1.2 : 1.0)
                    
                    Text(isWatchLater ? "Added" : "Watch Later")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isWatchLater ? .orange : .primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isWatchLater ? Color.orange.opacity(0.1) : Color(.systemGray5))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Share Button
            Button(action: {
                // Handle share action
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color(.systemGray5))
                    )
            }
        }
    }
    
    private var playbackControlsSection: some View {
        VStack(spacing: 20) {
            // Playback Speed Control
            HStack {
                Text("Playback Speed")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    showSpeedMenu = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "speedometer")
                            .font(.system(size: 14))
                        Text("\(playbackRate, specifier: "%.1fx")")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.purple.opacity(0.1))
                    )
                    .foregroundColor(.purple)
                }
            }
            
            // Speed Selection Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach([0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0], id: \.self) { rate in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                playbackRate = Float(rate)
                                player?.rate = isPlaying ? playbackRate : 0
                            }
                        }) {
                            Text("\(rate, specifier: "%.2fx")")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(rate == Double(playbackRate) ? .white : .primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(rate == Double(playbackRate) ? Color.purple : Color(.systemGray5))
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var podcastInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(podcast.title)
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: 12) {
                // Author info with avatar placeholder
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text(String(podcast.author.prefix(1)))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.purple)
                        )
                    
                    Text(podcast.author)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // View count or duration placeholder
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("12 min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Description with expand/collapse
            VStack(alignment: .leading, spacing: 8) {
                Text(podcast.description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(showFullDescription ? nil : 3)
                    .animation(.easeInOut(duration: 0.3), value: showFullDescription)
                
                if podcast.description.count > 100 {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showFullDescription.toggle()
                        }
                    }) {
                        Text(showFullDescription ? "Show less" : "Show more")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
        .padding(.vertical, 4)
    }
    
    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Up Next")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("See All") {
                    // Handle see all action
                }
                .font(.subheadline)
                .foregroundColor(.purple)
            }
            .padding(.horizontal, 16)
            
            LazyVStack(spacing: 16) {
                ForEach(allPodcasts.filter { $0.id != podcast.id }.prefix(5), id: \.id) { item in
                    NavigationLink(destination: VideoPlayerScreen(podcast: item, allPodcasts: allPodcasts)) {
                        recommendedItemView(item: item)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 32)
    }
    
    private func recommendedItemView(item: Podcast) -> some View {
        HStack(spacing: 16) {
            // Thumbnail with play overlay
            ZStack {
                AsyncImage(url: URL(string: item.thumbnail_url ?? "")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else if phase.error != nil {
                        Rectangle()
                            .fill(Color(.systemGray4))
                            .overlay(
                                Image(systemName: "play.rectangle.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
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
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "play.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(item.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 8) {
                    Text(item.author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 3, height: 3)
                    
                    Text("12 min")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private var speedMenuSheet: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Speed options
                VStack(spacing: 0) {
                    ForEach([0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0], id: \.self) { rate in
                        Button(action: {
                            playbackRate = Float(rate)
                            player?.rate = isPlaying ? playbackRate : 0
                            showSpeedMenu = false
                        }) {
                            HStack {
                                Text("\(rate, specifier: "%.2fx")")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                if rate == 1.0 {
                                    Text("Normal")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if rate == Double(playbackRate) {
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
                                .fill(rate == Double(playbackRate) ? Color.purple.opacity(0.1) : Color.clear)
                        )
                        
                        if rate != 2.0 {
                            Divider()
                                .padding(.leading, 20)
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Playback Speed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showSpeedMenu = false
                    }
                    .foregroundColor(.purple)
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func setupPlayer() {
        player?.play()
        isPlaying = true
        isLoading = false
        
        // Monitor playback status
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            isPlaying = false
        }
    }
    
    // MARK: - Player Logic
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
    
    private func initializePlayer() {
        guard let urlString = podcast.stream_url, let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Setup player status monitoring
        playerManager.setupPlayer(player: player!)
        
        // Monitor player status changes
        playerManager.onStatusChange = { status in
            DispatchQueue.main.async {
                switch status {
                case .readyToPlay:
                    isLoading = false
                    setupPlayer()
                case .failed:
                    isLoading = false
                    // Handle error
                case .unknown:
                    break
                @unknown default:
                    break
                }
            }
        }
        
        // Monitor play/pause state
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            isPlaying = false
        }
        fetchLibraryStatus()
    }
    
    private func cleanup() {
        player?.pause()
        playerManager.cleanup()
        NotificationCenter.default.removeObserver(self)
    }
    private func fetchLibraryStatus() {
        LibraryService.shared.updateLibrary(
            podcastId: podcast.id,
            userId: userUID,
            isLiked: nil,
            isWatchLater: nil
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let state):
                    self.isLiked = state.isLiked
                    self.isWatchLater = state.isWatchLater
                    print("✅ Synced library state: liked=\(state.isLiked), watchLater=\(state.isWatchLater)")
                case .failure(let error):
                    print("❌ Failed to fetch library state: \(error)")
                }
            }
        }
    }

}


// MARK: - Player Manager
class PlayerManager: ObservableObject {
    private var statusObserver: NSKeyValueObservation?
    var onStatusChange: ((AVPlayerItem.Status) -> Void)?
    
    func setupPlayer(player: AVPlayer) {
        guard let playerItem = player.currentItem else { return }
        
        statusObserver = playerItem.observe(\.status, options: [.new, .old]) { [weak self] item, _ in
            self?.onStatusChange?(item.status)
        }
    }
    
    func cleanup() {
        statusObserver?.invalidate()
        statusObserver = nil
    }
}
