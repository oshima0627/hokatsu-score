/// 障害等級
enum DisabilityGrade {
  none('なし'),
  physical1to2('身体障害者手帳 1〜2級'),
  physical3('身体障害者手帳 3級'),
  physical4to6('身体障害者手帳 4〜6級'),
  mental1('精神障害者保健福祉手帳 1級'),
  mental2('精神障害者保健福祉手帳 2級'),
  mental3('精神障害者保健福祉手帳 3級'),
  nursingA('療育手帳 A'),
  nursingB('療育手帳 B'),
  pensionA('障害年金 1級'),
  pensionB('障害年金 2級');

  const DisabilityGrade(this.displayName);

  /// UI表示用の名称
  final String displayName;
}
