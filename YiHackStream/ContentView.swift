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
        let media = VLCMedia(url: URL(string: "rtsp://192.168.1.127/ch0_0.h264")!)
        mediaPlayer.media = media
        mediaPlayer.play()
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
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
