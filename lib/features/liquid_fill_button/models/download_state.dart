/// The four distinct phases of the Liquid Fill Button lifecycle.
enum DownloadState {
  /// Button is at rest — "Download" label visible
  idle,

  /// Liquid is actively rising — percentage counter visible
  filling,

  /// Liquid is at 100% — checkmark drawing
  complete,
}
