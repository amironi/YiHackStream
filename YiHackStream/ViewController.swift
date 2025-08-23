import UIKit
import MobileVLCKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    private var mediaPlayer: VLCMediaPlayer!
    private var videoView: UIView!
    
    // RTSP URL
    private let rtspURL = "rtsp://192.168.1.127/ch0_0.h264"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMediaPlayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Start streaming after view is fully loaded and visible
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.startStreaming()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if mediaPlayer?.isPlaying == true {
            mediaPlayer.stop()
        }
    }
    
    deinit {
        mediaPlayer?.stop()
        mediaPlayer = nil
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Set background to black
        view.backgroundColor = .black
        
        // Create video view that fills entire screen
        videoView = UIView()
        videoView.backgroundColor = .black
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.clipsToBounds = true
        view.addSubview(videoView)
        
        // Constraints for full screen
        NSLayoutConstraint.activate([
            videoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Media Player Setup
    private func setupMediaPlayer() {
        // Initialize VLC media player
        mediaPlayer = VLCMediaPlayer()
        mediaPlayer.delegate = self
        
        // IMPORTANT: Set drawable AFTER view is laid out
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.mediaPlayer.drawable = self.videoView
        }
        
        // Configure media player options for better RTSP performance
        guard let url = URL(string: rtspURL) else {
            print("Invalid RTSP URL")
            return
        }
        
        let media = VLCMedia(url: url)
        
        // Add VLC options for iOS video output and RTSP streaming
        media.addOption("--network-caching=300")     // Network caching in ms
        media.addOption("--rtsp-tcp")                // Use TCP for RTSP (more reliable)
        media.addOption("--live-caching=300")        // Live stream caching
        media.addOption("--clock-jitter=0")          // Reduce jitter
        media.addOption("--clock-synchro=0")         // Disable clock synchronization
        // media.addOption("--vout=ios_eagl")           // iOS video output
        media.addOption("--avcodec-hw=any")          // Hardware acceleration
        
        mediaPlayer.media = media
    }
    
    // MARK: - Streaming Control
    private func startStreaming() {
        guard let mediaPlayer = mediaPlayer else {
            print("Media player not initialized")
            return
        }
        
        if !mediaPlayer.isPlaying {
            print("Starting RTSP stream...")
            mediaPlayer.play()
        }
    }
    
    private func stopStreaming() {
        guard let mediaPlayer = mediaPlayer else { return }
        
        if mediaPlayer.isPlaying {
            print("Stopping RTSP stream...")
            mediaPlayer.stop()
        }
    }
    
    // MARK: - Status Bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}

// MARK: - VLCMediaPlayerDelegate
extension ViewController: VLCMediaPlayerDelegate {
    
    func mediaPlayerStateChanged(_ aNotification: Notification) {
        guard let player = aNotification.object as? VLCMediaPlayer else { return }
        
        switch player.state {
        case .playing:
            print("RTSP Stream: Playing")
            
        case .paused:
            print("RTSP Stream: Paused")
            
        case .stopped:
            print("RTSP Stream: Stopped")
            
        case .ended:
            print("RTSP Stream: Ended")
            // Auto-reconnect if stream ends
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.startStreaming()
            }
            
        case .error:
            print("RTSP Stream: Error occurred")
            // Auto-reconnect on error
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                self?.startStreaming()
            }
            
        case .buffering:
            let bufferProgress = Int(player.position * 100)
            print("RTSP Stream: Buffering... \(bufferProgress)%")
            
        case .opening:
            print("RTSP Stream: Opening...")
            
        default:
            break
        }
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification) {
        // Can be used to track playback time if needed
    }
}
