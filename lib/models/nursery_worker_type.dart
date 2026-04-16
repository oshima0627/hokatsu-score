/// 保育士・子育て支援員の区分（排他的選択）
enum NurseryWorkerType {
  none('該当なし'),
  nurseryWorker('保育士'),
  childcareSupporter('子育て支援員');

  const NurseryWorkerType(this.displayName);

  /// UI表示用の名称
  final String displayName;
}
