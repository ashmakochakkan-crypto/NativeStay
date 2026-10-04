

/// Strips zero-width chars and unifies every kind of unicode space.
String normalizeText(String s) {
  return s
      .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF\u2060]'), '')
      .replaceAll(
        RegExp(r'[\s\u00A0\u1680\u2000-\u200A\u2028\u2029\u202F\u205F\u3000]+'),
        ' ',
      )
      .trim();
}

/// Title-cases a state name after whitespace cleanup.
String normalizeState(String s) {
  final cleaned = normalizeText(s);
  if (cleaned.isEmpty) return '';
  return cleaned
      .split(' ')
      .map((w) => w.isEmpty
          ? w
          : w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
}

int _levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  var prev = List<int>.generate(b.length + 1, (i) => i);
  var curr = List<int>.filled(b.length + 1, 0);
  for (var i = 1; i <= a.length; i++) {
    curr[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      final del = curr[j - 1] + 1;
      final ins = prev[j] + 1;
      final sub = prev[j - 1] + cost;
      curr[j] = del < ins ? (del < sub ? del : sub) : (ins < sub ? ins : sub);
    }
    final t = prev; prev = curr; curr = t;
  }
  return prev[b.length];
}

String canonicalStateKey(String raw) {
  final n = normalizeState(raw);
  if (n.isEmpty) return 'Other';
  final lower = n.toLowerCase();
  for (final s in kStateTaglines.keys) {
    if (s.toLowerCase() == lower) return s;
  }
  String best = '';
  int bestDist = 3;
  for (final s in kStateTaglines.keys) {
    final d = _levenshtein(lower, s.toLowerCase());
    if (d < bestDist) { bestDist = d; best = s; }
  }
  return best.isNotEmpty ? best : n;
}
// ⚠️ REPLACE THIS WITH YOUR REAL TAGLINES IF YOU FIND THEM ⚠️
const Map<String, String> kStateTaglines = {
  'Goa': 'Sun, sand, and susegad.',
  'Kerala': 'God\'s own country.',
  'Rajasthan': 'The land of kings.',
  'Himachal Pradesh': 'Mountains and magic.',
  'Maharashtra': 'Unlimited possibilities.',
  'Karnataka': 'One state, many worlds.',
  'Tamil Nadu': 'Enchanting Tamil Nadu.',
  'West Bengal': 'Beautiful Bengal.',
  'Uttarakhand': 'Simply heaven.',
};

String stateTagline(String state) {
  return kStateTaglines[state] ?? '';
}