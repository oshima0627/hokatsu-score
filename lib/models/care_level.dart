/// 介護の要介護・要支援度
enum CareLevel {
  none('なし'),
  support1('要支援1'),
  support2('要支援2'),
  care1('要介護1'),
  care2('要介護2'),
  care3('要介護3'),
  care4('要介護4'),
  care5('要介護5');

  const CareLevel(this.displayName);

  /// UI表示用の名称
  final String displayName;
}
