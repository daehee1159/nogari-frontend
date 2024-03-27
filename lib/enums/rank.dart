enum Rank {
  private,
  privateFirst,
  corporal,
  sergeant,

}

Rank getRankFromString(String str) {
  return Rank.values.firstWhere((e) => e.toString().split('.').last == str.toLowerCase(), orElse: () => Rank.private);
}
