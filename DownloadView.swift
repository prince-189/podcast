//import SwiftUI
//import AVFoundation
//
//struct DownloadView: View {
//    @ObservedObject var downloadManager = DownloadManager.shared
//
//    var body: some View {
//        NavigationView {
//            List {
//                Section(header: Text("Currently Downloading")) {
//                    ForEach(downloadManager.downloads.sorted(by: { $0.key < $1.key }), id: \.key) { podcastId, progress in
//                        VStack(alignment: .leading) {
//                            Text("Podcast ID: \(podcastId)")
//                                .font(.headline)
//                            
//                            if progress < 1.0 {
//                                ProgressView(value: progress)
//                            } else {
//                                Text("Downloaded")
//                                    .font(.caption)
//                                    .foregroundColor(.green)
//                            }
//                        }
//                    }
//                }
//                
//                Section(header: Text("Downloaded")) {
//                    ForEach(downloadManager.downloadedPodcasts, id: \.id) { podcast in
//                        NavigationLink(destination: OfflinePlayerView(podcast: podcast)) {
//                            HStack {
//                                VStack(alignment: .leading) {
//                                    Text(podcast.title)
//                                        .font(.headline)
//                                    Text(podcast.author)
//                                        .font(.subheadline)
//                                        .foregroundColor(.secondary)
//                                }
//                                Spacer()
//                                Image(systemName: "play.circle.fill")
//                                    .font(.title2)
//                            }
//                        }
//
//                    }
//                }
//            }
//            .navigationTitle("Downloads")
//            .onAppear {
//                downloadManager.loadDownloadedPodcasts()
//            }
//        }
//    }
//
//    func playDownloaded(podcast: Podcast) {
//        let fileURL = FileManager.default
//            .urls(for: .documentDirectory, in: .userDomainMask)[0]
//            .appendingPathComponent("\(podcast.id).mp3")
//
//        let player = AVPlayer(url: fileURL)
//        player.play()
//    }
//}
//
//
//struct OfflinePlayerView: View {
//    let podcast: Podcast
//
//    @State private var player: AVPlayer?
//    @State private var isPlaying = false
//    @State private var currentTime: Double = 0
//    @State private var duration: Double = 1 // default to 1 to avoid divide-by-zero
//    @State private var timeObserverToken: Any?
//
//    var body: some View {
//        VStack(spacing: 24) {
//            // Title
//            VStack(spacing: 6) {
//                Text(podcast.title)
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .multilineTextAlignment(.center)
//
//                Text(podcast.author)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//
//            // Playback Slider
//            VStack {
//                Slider(value: $currentTime, in: 0...duration, onEditingChanged: { editing in
//                    if !editing {
//                        player?.seek(to: CMTime(seconds: currentTime, preferredTimescale: 600))
//                    }
//                })
//                .accentColor(.purple)
//
//                HStack {
//                    Text(formatTime(currentTime))
//                        .font(.caption)
//                    Spacer()
//                    Text(formatTime(duration))
//                        .font(.caption)
//                }
//                .padding(.horizontal, 4)
//            }
//
//            // Controls
//            HStack(spacing: 40) {
//                Button {
//                    seek(by: -15)
//                } label: {
//                    Image(systemName: "gobackward.15")
//                        .font(.system(size: 28))
//                }
//
//                Button {
//                    togglePlayPause()
//                } label: {
//                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
//                        .font(.system(size: 56))
//                        .foregroundColor(.purple)
//                }
//
//                Button {
//                    seek(by: 15)
//                } label: {
//                    Image(systemName: "goforward.15")
//                        .font(.system(size: 28))
//                }
//            }
//
//            Spacer()
//        }
//        .padding()
//        .onAppear {
//            setupPlayer()
//        }
//        .onDisappear {
//            cleanup()
//        }
//    }
//
//    // MARK: - Player Setup
//
//    func setupPlayer() {
//        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            .appendingPathComponent("\(podcast.id).mp3")
//
//        let avPlayer = AVPlayer(url: fileURL)
//        self.player = avPlayer
//
//        // Get duration after asset is ready
//        avPlayer.currentItem?.asset.loadValuesAsynchronously(forKeys: ["duration"]) {
//            let durationSeconds = avPlayer.currentItem?.asset.duration.seconds ?? 0
//            DispatchQueue.main.async {
//                self.duration = durationSeconds
//            }
//        }
//
//        // Observe time
//        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
//        timeObserverToken = avPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
//            self.currentTime = time.seconds
//        }
//
//        // Start playing
//        avPlayer.play()
//        isPlaying = true
//    }
//
//    func togglePlayPause() {
//        guard let player = player else { return }
//        if isPlaying {
//            player.pause()
//        } else {
//            player.play()
//        }
//        isPlaying.toggle()
//    }
//
//    func seek(by seconds: Double) {
//        guard let player = player else { return }
//        let newTime = max(0, min(currentTime + seconds, duration))
//        player.seek(to: CMTime(seconds: newTime, preferredTimescale: 600))
//    }
//
//    func cleanup() {
//        if let token = timeObserverToken {
//            player?.removeTimeObserver(token)
//            timeObserverToken = nil
//        }
//        player?.pause()
//        player = nil
//    }
//
//    func formatTime(_ seconds: Double) -> String {
//        let minutes = Int(seconds) / 60
//        let sec = Int(seconds) % 60
//        return String(format: "%02d:%02d", minutes, sec)
//    }
//}
