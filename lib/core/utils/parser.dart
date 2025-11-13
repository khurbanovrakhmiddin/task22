class AppParser{

  static String timeFormatter(Duration? duration) {

    if(duration == null||duration == Duration.zero){
      return "--:--";
    }
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}