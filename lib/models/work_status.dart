/// 就労状況（保護者の保育を必要とする事由）
enum WorkStatus {
  /// 未選択（初期値・バリデーション用）
  notSpecified('未選択'),

  /// 就労中（雇用契約あり）
  employed('就労中（雇用契約あり）'),

  /// 採用予定
  employedProspect('採用予定'),

  /// 自営業（証明書なし）
  selfEmployedNoProof('自営業（証明書なし）'),

  /// 妊娠中（単胎）
  pregnant('妊娠中（単胎）'),

  /// 妊娠中（多胎）
  pregnantMultiple('妊娠中（多胎）'),

  /// 入院・常時臥床
  hospitalizedBedridden('入院・常時臥床'),

  /// 療養中（重度）
  medicalTreatmentSerious('療養中（重度）'),

  /// 療養中（軽度）
  medicalTreatmentMild('療養中（軽度）'),

  /// 介護中
  caregiving('介護中'),

  /// 就学・職業訓練
  student('就学・職業訓練'),

  /// 求職中
  jobSeeking('求職中'),

  /// 育休中
  parentalLeave('育休中'),

  /// みなし育休中
  pseudoParentalLeave('みなし育休中');

  const WorkStatus(this.displayName);

  /// UI表示用の名称
  final String displayName;
}
