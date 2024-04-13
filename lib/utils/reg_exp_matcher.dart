String regHrefMatcher(String input) {
  RegExp exp = RegExp(r'href="([^"]+)"');
  Iterable<Match> matches = exp.allMatches(input);
  String? firstMatch = matches.first.group(1);
  return firstMatch!;
}

String regDataSrcMatcher(String input) {
  RegExp exp = RegExp(r'data-src="([^"]+)"');
  Iterable<Match> matches = exp.allMatches(input);
  String? firstMatch = matches.first.group(1);
  return firstMatch!;
}

String regSrcMatcher(String input) {
  RegExp exp = RegExp(r'src="([^"]+)"');
  Iterable<Match> matches = exp.allMatches(input);
  String? firstMatch = matches.first.group(1);
  return firstMatch!;
}

String regImgMatcher(String input) {
  RegExp exp = RegExp(r'img="([^"]+)"');
  Iterable<Match> matches = exp.allMatches(input);
  String? firstMatch = matches.first.group(1);
  return firstMatch!;
}

String regCustomMatcher(
  String input,
  String source,
  int group,
) {
  try {
    RegExp exp = RegExp(source);
    Iterable<Match> matches = exp.allMatches(input);
    String? firstMatch = matches.first.group(group);
    return firstMatch!;
  } catch (_) {
    return input;
  }
}

String padIndex(int index) {
  String idx = index.toString();

  if (idx.length == 1) {
    return '00$idx';
  } else if (idx.length == 2) {
    return '0$idx';
  }
  return idx;
}
