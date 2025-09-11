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
    }
    
     func playRTSP() {
        guard let mediaPlayer = vlcMediaPlayer else { return }
        
        // Move network operations to background queue
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // Create media with RTSP URL
            let url = URL(string: "rtsp://192.168.1.127/ch0_0.h264")!
            
            let media = VLCMedia(url: url)
            // Enhanced network options for reliable RTSP streaming
            media.addOption("--rtsp-tcp")
            media.addOption("--network-caching=300")
            media.addOption("--rtsp-caching=300")
            media.addOption("--rtsp-frame-buffer-size=500000")
            
            DispatchQueue.main.async {
                mediaPlayer.media = media
                mediaPlayer.play()
            }
        }
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
