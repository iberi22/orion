/// Shared TTS types
enum TTSState {
  uninitialized,
  initialized,
  starting,
  speaking,
  paused,
  continued,
  stopped,
  completed,
  cancelled,
  error,
}
