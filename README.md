# Orion: AI-Powered Voice Assistant

Orion is a cutting-edge Flutter application that combines advanced AI capabilities with intuitive voice interaction to create a personalized spiritual and wellness guide. Built with Google Cloud Vertex AI integration and real-time audio visualization, Orion provides a seamless voice-first experience across web and mobile platforms.

## ✨ Key Features

### 🎤 **Advanced Voice Interaction**

- **Real-time Speech Transcription** powered by Google Cloud Vertex AI (Gemini 1.5 Flash)
- **Conversational AI** with context awareness and memory
- **Cross-browser Audio Support** with automatic fallbacks
- **Intelligent Error Handling** with multiple fallback mechanisms

### 📊 **Rich Visual Feedback**

- **Real-time Audio Waveform Visualizer** with multiple styles (bars, line, dots)
- **Volume Level Indicators** with optimal recording range guidance
- **Smooth Animations** and state transitions for enhanced UX
- **Responsive Visual Components** that adapt to voice interaction states

### 🌐 **Cross-Platform Compatibility**

- **Web Optimized** with browser-specific audio optimizations
- **Mobile Ready** for iOS and Android platforms
- **Permission Management** with user-friendly guidance for each browser
- **Progressive Enhancement** with graceful degradation

### 🔒 **Production-Ready Architecture**

- **Secure API Integration** with proper credential management
- **Comprehensive Error Handling** and retry mechanisms
- **Performance Optimized** for smooth 60fps animations
- **Configurable Settings** through environment variables

## Project Overview

Orion leverages modern AI technologies to provide personalized guidance through meditation, self-awareness, and consciousness exploration. The application features a sophisticated voice interaction system that makes spiritual guidance accessible and engaging.

For detailed project documentation, see the [Project Brief](documentacion_orion/docs/1-PROJECT_BRIEF.md).

## 🚀 Quick Start

### Prerequisites

- **Flutter SDK** (^3.7.2) - [Installation Guide](https://docs.flutter.dev/get-started/install)
- **Google Cloud Account** with Vertex AI API enabled
- **Gemini API Key** - [Get your key here](https://aistudio.google.com/app/apikey)

### Installation

1. **Clone the repository:**

   ```bash
   git clone <repository-url>
   cd orion
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Configure environment variables:**

   ```bash
   cp .env.example .env
   ```

   Edit `.env` and add your API keys:

   ```env
   # Firebase Configuration
   GEMINI_API_KEY=your_gemini_api_key_here

   # Vertex AI Configuration
   VERTEX_AI_PROJECT_ID=your-project-id
   VERTEX_AI_LOCATION=us-central1

   # Audio Configuration
   MAX_RECORDING_DURATION=60
   WEB_AUDIO_SAMPLE_RATE=44100
   WEB_AUDIO_BIT_RATE=128000

   # AI Configuration
   MAX_AI_TOKENS=2048
   AI_REQUEST_TIMEOUT=30
   AI_MAX_RETRIES=3
   AI_TEXT_TEMPERATURE=0.7
   AI_TRANSCRIPTION_TEMPERATURE=0.1
   ```

4. **Run the application:**

   ```bash
   # For web (recommended for voice features)
   flutter run -d chrome

   # For mobile
   flutter run

   # For production web build
   flutter build web --release
   ```

## 🌐 Browser Compatibility

### Supported Browsers

| Browser | Voice Recording | Audio Playback | Visual Feedback | Permission Management |
|---------|----------------|----------------|-----------------|----------------------|
| **Chrome** | ✅ Full Support | ✅ | ✅ | ✅ |
| **Firefox** | ✅ Full Support | ✅ | ✅ | ✅ |
| **Safari** | ✅ Limited* | ✅ | ✅ | ✅ |
| **Edge** | ✅ Full Support | ✅ | ✅ | ✅ |

*Safari has some limitations with WebRTC audio recording but includes fallbacks.

### Browser-Specific Features

- **Automatic browser detection** and capability checking
- **Optimized audio settings** for each browser
- **Graceful fallbacks** for unsupported features
- **User-friendly permission guidance** with browser-specific instructions

## 🎨 Visual Components

### Audio Waveform Visualizer

Real-time visualization of audio input with multiple display styles:

```dart
AudioWaveformVisualizer(
  isActive: true,
  volumeLevels: audioLevels, // Real-time audio data
  height: 60,
  width: 200,
  style: WaveformStyle.bars, // bars, line, or dots
  primaryColor: Colors.blue,
  animationDuration: Duration(milliseconds: 150),
)
```

**Features:**

- **Multiple Styles:** Bars, line, and dots visualization
- **Smooth Animations:** Fluid transitions with customizable duration
- **Real-time Updates:** Responds to live audio stream data
- **Customizable:** Colors, sizes, and animation parameters

### Volume Level Indicator

Visual feedback for optimal recording levels:

```dart
VolumeLevelIndicator(
  isActive: true,
  volumeLevel: 0.5, // 0.0 to 1.0
  size: 80,
  style: VolumeIndicatorStyle.circular, // circular, linear, or meter
  primaryColor: Colors.green,
  warningColor: Colors.orange,
  dangerColor: Colors.red,
  showOptimalRange: true,
)
```

**Features:**

- **Color-coded Feedback:** Green (good), orange (warning), red (too loud)
- **Peak Detection:** Shows peak levels with decay over time
- **Optimal Range Display:** Visual indication of ideal recording levels
- **Multiple Styles:** Circular, linear, and meter displays

## 🔧 Architecture

### AI Services Integration

- **Vertex AI (Gemini 1.5 Flash)** for speech transcription and conversation
- **Firebase AI** for seamless cloud integration
- **Retry Logic** with exponential backoff for reliability
- **Fallback Mechanisms** for graceful error handling

### Audio Processing Pipeline

1. **Browser Detection** → Optimize settings for specific browser
2. **Permission Request** → User-friendly guidance for microphone access
3. **Audio Capture** → High-quality recording with real-time monitoring
4. **Visual Feedback** → Live waveform and volume level display
5. **AI Transcription** → Convert speech to text using Vertex AI
6. **Response Generation** → Context-aware AI conversation
7. **Text-to-Speech** → Natural voice response playback

### State Management

- **Reactive Architecture** with stream-based state updates
- **Animation Controllers** for smooth visual transitions
- **Error Boundaries** with comprehensive error handling
- **Performance Optimization** for 60fps rendering

## 🧪 Testing

### Running Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Web-specific tests
flutter test --platform chrome
```

### Cross-Browser Testing

Test the voice features across different browsers:

1. **Chrome:** `flutter run -d chrome`
2. **Firefox:** `flutter run -d web-server` → Open in Firefox
3. **Safari:** `flutter run -d web-server` → Open in Safari
4. **Edge:** `flutter run -d edge`

### Manual Testing Checklist

- [ ] Microphone permission request works in each browser
- [ ] Audio recording starts and stops correctly
- [ ] Visual feedback (waveform/volume) updates in real-time
- [ ] AI transcription produces accurate results
- [ ] Voice responses play back clearly
- [ ] Error handling provides helpful guidance

## 🔒 Security

### API Key Management

- **Environment Variables:** All sensitive data in `.env` files
- **Git Ignore:** `.env` files are excluded from version control
- **No Hardcoded Secrets:** All credentials loaded from environment
- **Validation:** Configuration validation on app startup

### Browser Security

- **Permission Handling:** Secure microphone access requests
- **Input Validation:** Audio data and AI response validation
- **Error Boundaries:** Prevent sensitive data exposure in errors
- **HTTPS Required:** Secure connections for production deployment

## 📱 Deployment

### Web Deployment

```bash
# Build for production
flutter build web --release --web-renderer canvaskit

# Deploy to Firebase Hosting (optional)
firebase deploy --only hosting
```

### Mobile Deployment

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 🛠️ Development Guidelines

All development should follow the guidelines in [GEMINI.md](GEMINI.md), including:

- **Code Style:** Consistent formatting and naming conventions
- **Testing:** Comprehensive unit and integration tests
- **Documentation:** Clear code comments and API documentation
- **Performance:** Optimization for smooth user experience

## 📚 Documentation

Project documentation is in the `documentacion_orion/` directory:

- **[Project Brief](documentacion_orion/docs/1-PROJECT_BRIEF.md):** Vision and architecture
- **[Persona](documentacion_orion/docs/2-PERSONA.md):** AI agent personality
- **[Prompt Engineering](documentacion_orion/docs/3-PROMPT_ENGINEERING.md):** AI conversation design
- **[RAG Datasets](documentacion_orion/docs/4-RAG_DATASETS.md):** Knowledge sources
- **[Evaluation](documentacion_orion/docs/5-EVALUATION.md):** Performance metrics
- **[Epics](documentacion_orion/docs/epics/):** Development phases

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:

- **Issues:** [GitHub Issues](../../issues)
- **Documentation:** Check the `docs/` directory
- **Community:** [Discussions](../../discussions)

---

**Built with ❤️ using Flutter and Google Cloud Vertex AI**
