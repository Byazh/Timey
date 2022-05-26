String formatDate(DateTime dateTime) {
  return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
}

String formatTime(int time) {
  if (time.toString().length == 1) return "0$time";
  return "$time";
}