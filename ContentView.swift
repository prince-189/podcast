//
//  ContentView.swift
//  SOS
//
//  Created by Apple 12 on 03/07/25.
//
import SwiftUI
struct ContentView: View {
    @EnvironmentObject var auth: AuthManager

    var body: some View {
        Group {
            if auth.isLoggedIn {
                AudioverseMainView()
            } else {
                SignInView()
            }
        }
    }
}

// MARK :- python backend

//from flask import Flask, request, jsonify
//import subprocess
//import json
//
//app = Flask(__name__)
//
//@app.route("/stream-url", methods=["GET"])
//def get_stream_url():
//    video_url = request.args.get("url")
//    if not video_url:
//        return jsonify({"error": "No URL provided"}), 400
//
//    try:
//        result = subprocess.check_output([
//            "yt-dlp",
//            "--dump-single-json",
//            "-f", "best[ext=mp4]/best",
//            video_url
//        ])
//        info = json.loads(result.decode())
//
//        return jsonify({
//            "stream_url": info.get("url"),
//            "thumbnail_url": info.get("thumbnail"),
//            "title": info.get("title"),
//            "duration": info.get("duration")
//        })
//
//    except Exception as e:
//        return jsonify({"error": str(e)}), 500
//
//if __name__ == "__main__":
//    app.run(debug=True)
//
