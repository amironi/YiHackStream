import SwiftUI
import MobileVLCKit
import UIKit

// MARK: - VLC Player View
class VLCPlayerView: UIView {
    var vlcMediaPlayer: VLCMediaPlayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPlayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlayer()
    }
    
    private func setupPlayer() {
        backgroundColor = .black
        
        // Initialize VLC library with iOS-specific arguments
        let vlcArgs = [
            "--intf=dummy",
            "--no-interact",
            "--no-video-title-show",
            "--network-caching=1000",
            "--rtsp-caching=1000",
            "--live-caching=1000"
        ]
        
        let vlcLibrary = VLCLibrary(options: vlcArgs)
        
        vlcMediaPlayer = VLCMediaPlayer(library: vlcLibrary)
        vlcMediaPlayer?.drawable = self
        vlcMediaPlayer?.delegate = self
        
        // Set video output to ensure proper rendering
        vlcMediaPlayer?.videoAspectRatio = nil
        vlcMediaPlayer?.videoCropGeometry = nil
    }
    
     func playRTSP() {
        guard let mediaPlayer = vlcMediaPlayer else { 
            print("❌ VLC MediaPlayer not initialized")
            return 
        }
        
        print("🎬 Starting RTSP playback...")
        
        // Move network operations to background queue
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // Try multiple RTSP URL formats for Yi cameras
            let urlStrings = [
                "rtsp://192.168.1.127/ch0_0.h264",
            ]
            
            self?.tryRTSPUrls(urlStrings, mediaPlayer: mediaPlayer, index: 0)
        }
    }
    
    private func tryRTSPUrls(_ urls: [String], mediaPlayer: VLCMediaPlayer, index: Int) {
        guard index < urls.count else {
            print("❌ All RTSP URLs failed")
            print("📱 Network Debug Info:")
            print("   - Simulator uses Mac's network connection")
            print("   - iPhone uses its own Wi-Fi/cellular connection")
            print("   - Ensure iPhone is on same Wi-Fi as camera (192.168.1.127)")
            print("   - Try accessing http://192.168.1.127 in iPhone Safari")
            return
        }
        
        let urlString = urls[index]
        print("🔗 Trying URL \(index + 1)/\(urls.count): \(urlString)")
        
        // Extract IP for network testing
        if let url = URL(string: urlString), let host = url.host {
            print("📡 Testing network connectivity to \(host)...")
            testNetworkConnectivity(to: host)
        }
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid RTSP URL: \(urlString)")
            tryRTSPUrls(urls, mediaPlayer: mediaPlayer, index: index + 1)
            return
        }
        
        let media = VLCMedia(url: url)
        // No additional media options - use library-level configuration only
        
        print("📡 VLC options configured for \(urlString)")
        
        DispatchQueue.main.async { [weak self] in
            mediaPlayer.media = media
            mediaPlayer.play()
            print("▶️ VLC play() called for \(urlString)")
            
            // Wait 5 seconds, then check if playing, if not try next URL
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                if mediaPlayer.state != .playing {
                    print("⏭️ URL \(urlString) failed, trying next...")
                    self?.tryRTSPUrls(urls, mediaPlayer: mediaPlayer, index: index + 1)
                } else {
                    print("✅ Successfully connected to: \(urlString)")
                }
            }
        }
    }
    
    private func testNetworkConnectivity(to host: String) {
        let url = URL(string: "http://\(host)")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("🚫 Network test failed for \(host): \(error.localizedDescription)")
                } else if let httpResponse = response as? HTTPURLResponse {
                    print("✅ Network test successful for \(host): HTTP \(httpResponse.statusCode)")
                } else {
                    print("📡 Network response received from \(host)")
                }
            }
        }
        task.resume()
    }
}

// MARK: - VLC Delegate
extension VLCPlayerView: VLCMediaPlayerDelegate {
    func mediaPlayerStateChanged(_ aNotification: Notification) {
        guard let player = aNotification.object as? VLCMediaPlayer else { return }
        
        DispatchQueue.main.async {
            let state = player.state
            switch state {
            case .stopped:
                print("🛑 VLC State: Stopped")
            case .opening:
                print("🔄 VLC State: Opening...")
            case .buffering:
                print("⏳ VLC State: Buffering...")
            case .playing:
                print("✅ VLC State: Playing!")
            case .paused:
                print("⏸️ VLC State: Paused")
            case .ended:
                print("🏁 VLC State: Ended")
            case .error:
                print("❌ VLC State: Error!")
            case .esAdded:
                print("📺 VLC State: ES Added")
            @unknown default:
                print("❓ VLC State: Unknown (\(state.rawValue))")
            }
        }
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification) {
        // Optional: Track playback time
    }
}

// MARK: - SwiftUI Wrapper
struct VLCPlayerRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> VLCPlayerView {
        let playerView = VLCPlayerView()
        
        // Delay playback to ensure view is properly set up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            playerView.playRTSP()
        }
        
        return playerView
    }
    
    func updateUIView(_ playerView: VLCPlayerView, context: Context) {
        // Ensure drawable is properly set
        if let mediaPlayer = playerView.vlcMediaPlayer {
            mediaPlayer.drawable = playerView
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    var body: some View {
        VLCPlayerRepresentable()
            .ignoresSafeArea(.all)
    }
}



// MARK: - App Configuration
@main
struct VideoPlayerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
