# YiHackStream - RTSP Video Streaming App

A simple iOS app for streaming RTSP video feeds using VLC's MobileVLCKit framework.

## Features

- Full-screen RTSP video streaming
- Auto-reconnection on connection loss
- TCP-based RTSP for reliable streaming
- Optimized for Yi cameras and other RTSP sources

## Setup Instructions

### 1. Install Dependencies

```bash
pod install
```

### 2. Fix Framework Permissions (if build fails)

```bash
./fix_vlc_framework.sh
```

### 3. Configure RTSP URL

Edit `ViewController.swift` and update the RTSP URL:

```swift
private let rtspURL = "rtsp://YOUR_CAMERA_IP/ch0_0.h264"
```

### 4. Build and Run

- Open `YiHackStream.xcworkspace` in Xcode
- Select your target device/simulator
- Build and run (⌘+R)

## Configuration

### RTSP URL Examples

- Yi Camera: `rtsp://192.168.1.127/ch0_0.h264`
- Generic RTSP: `rtsp://username:password@ip:port/path`

### Network Requirements

- Ensure your iOS device is on the same network as the RTSP source
- The app includes local network usage permissions

## Troubleshooting

### Build Errors

If you encounter sandbox permission errors:

1. Run the fix script: `./fix_vlc_framework.sh`
2. Clean build folder in Xcode (⌘+Shift+K)
3. Rebuild the project

### Connection Issues

- Verify RTSP URL is accessible
- Check network connectivity
- Ensure camera/server supports TCP RTSP

### Performance Tips

- Use TCP mode for stable connections (already configured)
- Adjust network caching if needed (currently 300ms)
- Test on physical device for best performance

## Technical Details

- **Framework**: MobileVLCKit 3.6+
- **iOS Version**: 12.0+
- **Protocol**: RTSP over TCP
- **Video Output**: Native iOS video view

## License

This project is for educational and personal use.
