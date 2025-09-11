import SwiftUI
import MobileVLCKit
import UIKit

// MARK: - VLC Player View
class VLCPlayerView: UIView {
    private var vlcMediaPlayer: VLCMediaPlayer?
    
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
        
        vlcMediaPlayer = VLCMediaPlayer()
        vlcMediaPlayer?.drawable = self
        vlcMediaPlayer?.delegate = self
    }
    
     func playRTSP() {
        guard let mediaPlayer = vlcMediaPlayer else { 
            print("❌ VLC MediaPlayer not initialized")
            return 
        }
        
        print("🎬 Starting RTSP playback...")
        
        // Move network operations to background queue
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // Create media with RTSP URL
            let urlString = "rtsp://192.168.1.127/ch0_0.h264"
            print("🔗 Connecting to: \(urlString)")
            
            guard let url = URL(string: urlString) else {
                print("❌ Invalid RTSP URL")
                return
            }
            
            let media = VLCMedia(url: url)
            // Enhanced network options for reliable RTSP streaming
            media.addOption("--rtsp-tcp")
            media.addOption("--network-caching=300")
            media.addOption("--rtsp-caching=300")
            media.addOption("--rtsp-frame-buffer-size=500000")
            media.addOption("--verbose=2")
            
            print("📡 VLC options configured, starting playback...")
            
            DispatchQueue.main.async {
                mediaPlayer.media = media
                mediaPlayer.play()
                print("▶️ VLC play() called")
            }
        }
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
        playerView.playRTSP()
        return playerView
    }
    
    func updateUIView(_ playerView: VLCPlayerView, context: Context) {
        // Auto-play on update
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
