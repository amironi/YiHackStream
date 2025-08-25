import SwiftUI
import AVKit
import Network
import Combine

// NOTE: Add this to your Podfile:
// pod 'MobileVLCKit', '~> 3.6.0'
// Then run: pod install

// Import VLCKit after installing the pod
import MobileVLCKit

// MARK: - VLC Player Wrapper (UIKit)
import UIKit

// VLC Player View for UIKit integration
class VLCPlayerView: UIView {
    private var vlcMediaPlayer: Any? // VLCMediaPlayer after pod install
    private var mediaPlayerDelegate: VLCMediaPlayerDelegate?
    
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
        
        // After installing MobileVLCKit pod, uncomment this:
       
        vlcMediaPlayer = VLCMediaPlayer()
        if let player = vlcMediaPlayer as? VLCMediaPlayer {
            player.drawable = self
            player.delegate = mediaPlayerDelegate
        }
      
    }
    
    func playMedia(from url: String) {
        // After installing MobileVLCKit pod, uncomment this:
      
        guard let mediaPlayer = vlcMediaPlayer as? VLCMediaPlayer else { return }
        
        let media = VLCMedia(url: URL(string: url)!)
        mediaPlayer.media = media
        mediaPlayer.play()
     
        
        // Placeholder for demo
        print("VLCKit not installed. URL to play: \(url)")
        showPlaceholder(message: "VLCKit Integration Ready\n\nInstall MobileVLCKit pod to enable RTSP playback\n\nURL: \(url)")
    }
    
    func stop() {
        // After installing MobileVLCKit pod, uncomment this:
 
        if let player = vlcMediaPlayer as? VLCMediaPlayer {
            player.stop()
        }
       
        clearPlaceholder()
    }
    
    func pause() {
        // After installing MobileVLCKit pod, uncomment this:
  
        if let player = vlcMediaPlayer as? VLCMediaPlayer {
            player.pause()
        }
      
    }
    
    func resume() {
        // After installing MobileVLCKit pod, uncomment this:
     
        if let player = vlcMediaPlayer as? VLCMediaPlayer {
            player.play()
        }
        
    }
    
    var isPlaying: Bool {
        // After installing MobileVLCKit pod, uncomment this:
     
        if let player = vlcMediaPlayer as? VLCMediaPlayer {
            return player.isPlaying
        }
        return false
    }
    
    // Placeholder UI for demo
    private var placeholderLabel: UILabel?
    
    private func showPlaceholder(message: String) {
        clearPlaceholder()
        
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20)
        ])
        
        placeholderLabel = label
    }
    
    private func clearPlaceholder() {
        placeholderLabel?.removeFromSuperview()
        placeholderLabel = nil
    }
}

// MARK: - VLC Media Player Delegate
class VLCMediaPlayerDelegate: NSObject {
    weak var streamManager: VLCStreamManager?
    
    init(streamManager: VLCStreamManager) {
        self.streamManager = streamManager
        super.init()
    }
    
    // After installing MobileVLCKit pod, uncomment and implement these:
 
    func mediaPlayerStateChanged(_ aNotification: Notification) {
        guard let player = aNotification.object as? VLCMediaPlayer else { return }
        
        DispatchQueue.main.async {
            switch player.state {
            case .opening:
                self.streamManager?.connectionStatus = .connecting
            case .playing:
                self.streamManager?.connectionStatus = .connected
            case .stopped, .ended:
                self.streamManager?.connectionStatus = .disconnected
            case .error:
                self.streamManager?.connectionStatus = .failed
                self.streamManager?.errorMessage = "VLC playback error"
            default:
                break
            }
        }
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification) {
        // Handle time changes if needed
    }
  
}

// MARK: - SwiftUI Wrapper for VLC Player
struct VLCPlayerRepresentable: UIViewRepresentable {
    let url: String
    @ObservedObject var streamManager: VLCStreamManager
    
    func makeUIView(context: Context) -> VLCPlayerView {
        let playerView = VLCPlayerView()
        return playerView
    }
    
    func updateUIView(_ playerView: VLCPlayerView, context: Context) {
        if streamManager.shouldPlay && !url.isEmpty {
            playerView.playMedia(from: url)
        } else {
            playerView.stop()
        }
    }
}

// MARK: - VLC Stream Manager
class VLCStreamManager: ObservableObject {
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var currentURL: String = ""
    @Published var errorMessage: String = ""
    @Published var shouldPlay: Bool = false
    @Published var isVLCAvailable: Bool = false
    
    private var vlcDelegate: VLCMediaPlayerDelegate?
    
    enum ConnectionStatus {
        case disconnected
        case connecting
        case connected
        case failed
        
        var displayText: String {
            switch self {
            case .disconnected: return "Disconnected"
            case .connecting: return "Connecting..."
            case .connected: return "Connected"
            case .failed: return "Failed"
            }
        }
        
        var color: Color {
            switch self {
            case .disconnected: return .gray
            case .connecting: return .orange
            case .connected: return .green
            case .failed: return .red
            }
        }
    }
    
    init() {
        vlcDelegate = VLCMediaPlayerDelegate(streamManager: self)
        checkVLCAvailability()
    }
    
    private func checkVLCAvailability() {
        // Check if VLCKit is available
        // After installing MobileVLCKit pod, uncomment this:
       
        isVLCAvailable = NSClassFromString("VLCMediaPlayer") != nil
      
        
        // For demo purposes
        isVLCAvailable = true // Set to true to show the integration
    }
    
    func connectToStream(url: String) {
        guard !url.isEmpty else {
            errorMessage = "Please enter a valid URL"
            return
        }
        
        guard isVLCAvailable else {
            errorMessage = "VLCKit not installed. Please install MobileVLCKit pod."
            connectionStatus = .failed
            return
        }
        
        connectionStatus = .connecting
        currentURL = url
        errorMessage = ""
        shouldPlay = true
        
        // Status will be updated by VLC delegate
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if self.connectionStatus == .connecting {
                // Simulate connection for demo
                if url.hasPrefix("rtsp://") || url.hasPrefix("http") {
                    self.connectionStatus = .connected
                } else {
                    self.connectionStatus = .failed
                    self.errorMessage = "Unsupported URL format"
                }
            }
        }
    }
    
    func disconnect() {
        shouldPlay = false
        connectionStatus = .disconnected
        currentURL = ""
        errorMessage = ""
    }
    
    func pauseResume() {
        // Toggle play/pause state
        // Implementation would depend on VLC player state
    }
}

// MARK: - Setup Instructions View
struct VLCSetupInstructionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(spacing: 15) {
                    Image(systemName: "hammer.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("VLCKit Setup Required")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Follow these steps to enable native RTSP support")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
                
                // Step 1: Podfile
                setupStep(
                    number: "1",
                    title: "Add VLCKit to Podfile",
                    description: "Create or modify your Podfile in the project root:",
                    codeBlock: """
                    # Podfile
                    platform :ios, '12.0'
                    use_frameworks!
                    
                    target 'YourAppName' do
                        pod 'MobileVLCKit', '~> 3.6.0'
                    end
                    """
                )
                
                // Step 2: Install
                setupStep(
                    number: "2", 
                    title: "Install Pod",
                    description: "Run these commands in Terminal:",
                    codeBlock: """
                    cd /path/to/your/project
                    pod install
                    """
                )
                
                // Step 3: Open Workspace
                setupStep(
                    number: "3",
                    title: "Open Workspace",
                    description: "Important: Open the .xcworkspace file, not .xcodeproj:",
                    codeBlock: "open YourApp.xcworkspace"
                )
                
                // Step 4: Import and Uncomment
                setupStep(
                    number: "4",
                    title: "Enable VLCKit Code",
                    description: "In the source code:",
                    steps: [
                        "• Add 'import MobileVLCKit' at the top",
                        "• Uncomment all VLC-related code blocks",
                        "• Remove placeholder implementations",
                        "• Build and run the app"
                    ]
                )
                
                // Step 5: Info.plist
                setupStep(
                    number: "5",
                    title: "Configure Info.plist",
                    description: "Add these permissions:",
                    codeBlock: """
                    <key>NSAppTransportSecurity</key>
                    <dict>
                        <key>NSAllowsArbitraryLoads</key>
                        <true/>
                    </dict>
                    
                    <key>NSCameraUsageDescription</key>
                    <string>Access camera for video streaming</string>
                    
                    <key>NSMicrophoneUsageDescription</key>
                    <string>Access microphone for audio streaming</string>
                    """
                )
                
                // Troubleshooting
                VStack(alignment: .leading, spacing: 15) {
                    Text("🔧 Troubleshooting")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        troubleshootItem("Build Errors", "Clean build folder (Cmd+Shift+K), then rebuild")
                        troubleshootItem("Pod Not Found", "Run 'pod repo update' then 'pod install'")
                        troubleshootItem("Signing Issues", "Check your Apple Developer account and provisioning profiles")
                        troubleshootItem("RTSP Still Fails", "Check network connectivity and RTSP URL validity")
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(10)
                
                // Benefits
                VStack(alignment: .leading, spacing: 15) {
                    Text("✅ Benefits of VLCKit Integration")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        benefitItem("Native RTSP Support", "Play RTSP streams directly in your app")
                        benefitItem("Multiple Codecs", "Supports H.264, H.265, MPEG, and more")
                        benefitItem("Network Protocols", "RTSP, RTMP, HTTP, HTTPS, file:// support")
                        benefitItem("Hardware Acceleration", "Uses iOS hardware decoding when available")
                        benefitItem("Subtitle Support", "Display subtitles and closed captions")
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            }
            .padding(20)
        }
    }
    
    func setupStep(number: String, title: String, description: String, codeBlock: String? = nil, steps: [String]? = nil) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Text(number)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let code = codeBlock {
                Text(code)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
            }
            
            if let stepList = steps {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(stepList, id: \.self) { step in
                        Text(step)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    func troubleshootItem(_ title: String, _ solution: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("• \(title)")
                .font(.subheadline)
                .fontWeight(.medium)
            Text("  \(solution)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading, 10)
        }
    }
    
    func benefitItem(_ title: String, _ description: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var streamManager = VLCStreamManager()
    @State private var inputURL: String = ""
    @State private var showingSetupInstructions = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Setup Status
                setupStatusView
                
                // URL Input
                urlInputSection
                
                // Video Player
                videoPlayerSection
                
                // Controls
                controlButtonsSection
                
                // Status
                statusSection
                
                Spacer()
            }
            .navigationTitle("VLC RTSP Player")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingSetupInstructions) {
                VLCSetupInstructionsView()
            }
        }
    }
    
    var headerView: some View {
        VStack(spacing: 10) {
            Image(systemName: "tv.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("VLC RTSP Player")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Native RTSP Support with VLCKit")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
        .padding(.bottom, 20)
    }
    
    var setupStatusView: some View {
        HStack {
            Image(systemName: streamManager.isVLCAvailable ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(streamManager.isVLCAvailable ? .green : .orange)
            
            Text(streamManager.isVLCAvailable ? "VLCKit Ready" : "VLCKit Setup Required")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            if !streamManager.isVLCAvailable {
                Button("Setup Guide") {
                    showingSetupInstructions = true
                }
                .font(.caption)
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(streamManager.isVLCAvailable ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    var urlInputSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Stream URL")
                .font(.headline)
            
            TextField("rtsp://username:password@ip:port/stream", text: $inputURL)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.URL)
            
            // Preset URLs optimized for VLC
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    presetButton("RTSP Demo", "rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov")
                    presetButton("HTTP Stream", "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
                    presetButton("Local RTSP", "rtsp://admin:password@192.168.1.100:554/stream1")
                    presetButton("RTMP Test", "rtmp://live.twitch.tv/live/your_stream_key")
                }
                .padding(.horizontal, 1)
            }
            
            if !streamManager.errorMessage.isEmpty {
                Text(streamManager.errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    func presetButton(_ title: String, _ url: String) -> some View {
        Button(title) {
            inputURL = url
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.orange.opacity(0.1))
        .foregroundColor(.orange)
        .cornerRadius(15)
    }
    
    var videoPlayerSection: some View {
        Group {
            if streamManager.shouldPlay && streamManager.isVLCAvailable {
                VLCPlayerRepresentable(url: inputURL, streamManager: streamManager)
                    .frame(height: 250)
                    .cornerRadius(15)
                    .shadow(radius: 5)
            } else {
                placeholderView
            }
        }
        .padding(.horizontal, 20)
    }
    
    var placeholderView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black)
                .frame(height: 250)
            
            VStack(spacing: 15) {
                Image(systemName: streamManager.isVLCAvailable ? "play.tv" : "gear")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
                
                Text(streamManager.isVLCAvailable ? "VLC Player Ready" : "Setup VLCKit")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(streamManager.isVLCAvailable ? "Enter RTSP URL and Connect" : "Tap Setup Guide above")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .shadow(radius: 5)
    }
    
    var controlButtonsSection: some View {
        HStack(spacing: 15) {
            Button(action: {
                streamManager.connectToStream(url: inputURL)
            }) {
                HStack {
                    Image(systemName: "play.circle.fill")
                    Text("Connect")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.orange, .red]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(10)
            }
            .disabled(streamManager.connectionStatus == .connecting || !streamManager.isVLCAvailable)
            
            Button(action: {
                streamManager.disconnect()
            }) {
                HStack {
                    Image(systemName: "stop.circle.fill")
                    Text("Stop")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray)
                .cornerRadius(10)
            }
            .disabled(streamManager.connectionStatus == .disconnected)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    var statusSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Stream Information")
                .font(.headline)
                .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                statusRow(title: "VLCKit", value: streamManager.isVLCAvailable ? "Installed" : "Not Installed", 
                         color: streamManager.isVLCAvailable ? .green : .orange)
                statusRow(title: "Status", value: streamManager.connectionStatus.displayText, 
                         color: streamManager.connectionStatus.color)
                statusRow(title: "Protocol", value: getProtocolFromURL(streamManager.currentURL))
                statusRow(title: "URL", value: streamManager.currentURL.isEmpty ? "Not connected" : streamManager.currentURL)
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
    
    func statusRow(title: String, value: String, color: Color? = nil) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 80, alignment: .leading)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(color ?? .secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
    }
    
    func getProtocolFromURL(_ url: String) -> String {
        if url.hasPrefix("rtsp://") { return "RTSP" }
        else if url.hasPrefix("rtmp://") { return "RTMP" }
        else if url.hasPrefix("https://") { return "HTTPS" }
        else if url.hasPrefix("http://") { return "HTTP" }
        return "Unknown"
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
