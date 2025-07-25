////
////  DownloadManager.swift
////  SOS
////
////  Created by Apple 12 on 21/07/25.
////
//
//import Foundation
//import AVFoundation
//
//class DownloadManager: NSObject, ObservableObject, URLSessionDownloadDelegate {
//    static let shared = DownloadManager()
//    
//    @Published var downloads: [Int: Float] = [:] // podcastId : progress
//    @Published var downloadedPodcasts: [Podcast] = []
//
//    private var downloadTasks: [Int: URLSessionDownloadTask] = [:]
//    
//    private lazy var session: URLSession = {
//        let config = URLSessionConfiguration.default
//        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
//    }()
//    
//    // MARK: - Start Download
//    
//    func startDownload(podcast: Podcast) {
//        guard let url = URL(string: podcast.stream_url ?? "") else { return }
//
//        let task = session.downloadTask(with: url)
//        downloadTasks[podcast.id] = task
//        downloads[podcast.id] = 0
//        task.resume()
//    }
//    
//    // MARK: - URLSessionDownloadDelegate
//    
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
//                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
//                    totalBytesExpectedToWrite: Int64) {
//        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
//        
//        DispatchQueue.main.async {
//            if let podcastId = self.downloadTasks.first(where: { $0.value == downloadTask })?.key {
//                self.downloads[podcastId] = progress
//            }
//        }
//    }
//    
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
//                    didFinishDownloadingTo location: URL) {
//        guard let podcastId = downloadTasks.first(where: { $0.value == downloadTask })?.key else { return }
//
//        // Move file to Documents directory
//        let fileManager = FileManager.default
//        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let destination = documents.appendingPathComponent("\(podcastId).mp3")
//        
//        do {
//            if fileManager.fileExists(atPath: destination.path) {
//                try fileManager.removeItem(at: destination)
//            }
//            try fileManager.moveItem(at: location, to: destination)
//            print("✅ Downloaded and saved to \(destination)")
//        } catch {
//            print("❌ Error saving file: \(error)")
//        }
//
//        DispatchQueue.main.async {
//            self.downloads[podcastId] = 1.0
//        }
//
//        // Save podcast metadata locally
//        if let podcast = getPodcast(by: podcastId) {
//            savePodcastMetadata(podcast)
//        }
//    }
//    
//    // MARK: - Metadata Handling
//    
//    private func savePodcastMetadata(_ podcast: Podcast) {
//        var saved = loadSavedPodcastMetadata()
//        
//        // Avoid duplicates
//        if !saved.contains(where: { $0.id == podcast.id }) {
//            saved.append(podcast)
//            if let data = try? JSONEncoder().encode(saved) {
//                UserDefaults.standard.set(data, forKey: "downloaded_metadata")
//            }
//        }
//    }
//
//    private func loadSavedPodcastMetadata() -> [Podcast] {
//        guard let data = UserDefaults.standard.data(forKey: "downloaded_metadata"),
//              let podcasts = try? JSONDecoder().decode([Podcast].self, from: data) else {
//            return []
//        }
//        return podcasts
//    }
//
//    // MARK: - Load for Offline View
//
//    func loadDownloadedPodcasts() {
//        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        do {
//            let files = try FileManager.default.contentsOfDirectory(at: documents, includingPropertiesForKeys: nil)
//            
//            let downloadedIds: [Int] = files
//                .filter { $0.pathExtension == "mp3" }
//                .compactMap { Int($0.deletingPathExtension().lastPathComponent) }
//
//            let saved = loadSavedPodcastMetadata()
//            downloadedPodcasts = saved.filter { downloadedIds.contains($0.id) }
//            
//        } catch {
//            print("❌ Failed to read documents: \(error)")
//        }
//    }
//
//    // MARK: - Helpers
//    
//    func isDownloaded(podcastId: Int) -> Bool {
//        let path = FileManager.default
//            .urls(for: .documentDirectory, in: .userDomainMask)[0]
//            .appendingPathComponent("\(podcastId).mp3")
//        return FileManager.default.fileExists(atPath: path.path)
//    }
//
//    private func getPodcast(by id: Int) -> Podcast? {
//        // If you're downloading from HomeView and still have `allPodcasts`, replace this:
//        // You can customize this logic to retrieve podcast info from your current view
//        return nil // <- Update this to return the full Podcast if you have it
//    }
//}
