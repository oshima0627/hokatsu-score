/// 対応自治体（沖縄南部8市町）
enum Municipality {
  naha('那覇市'),
  urasoe('浦添市'),
  tomigusuku('豊見城市'),
  itoman('糸満市'),
  nanjo('南城市'),
  haebaru('南風原町'),
  yonabaru('与那原町'),
  yaese('八重瀬町');

  const Municipality(this.displayName);

  /// UI表示用の名称
  final String displayName;
}
