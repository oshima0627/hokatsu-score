# 自治体別スコアリングルール

> 親ドキュメント：[../../CLAUDE.md](../../CLAUDE.md)
> 関連：[../architecture.md](../architecture.md)

## 実装方針

各自治体ファイルは同じ `ScoringRule` を継承して実装する。
指数PDFは各自治体の公式サイトから取得し、`sourceUrl` および `fiscalYear` プロパティで明示する。

> ⚠️ 那覇市以外の指数表は実装前に必ず各自治体の公式PDFを確認すること。
> 配点スケールが自治体ごとに異なるため、コピーせず個別に実装する。

## 配点の検証フロー（実装着手時に必須）

各自治体のスコアリングルールを実装する際、以下の手順で**一次資料との突合**を行うこと：

1. 該当自治体の公式ページから最新年度のPDF（選考基準表）を取得
2. 取得日・ファイル名・URL・対象年度を当該自治体のドキュメント（`docs/scoring/<municipality>.md`）に記載
3. 基本指数・調整指数の**全配点**を PDF と 1:1 で突合し、差分があれば本ドキュメントと実装を更新
4. **検証済みタイムスタンプ**（例：`検証日: 2026-04-15 / PDF更新日: 2026-03-01`）を各ドキュメントに残す
5. 年度更新のたびに本手順を繰り返す

## ボーダー点データ（v2 候補）

那覇市は公式ページで **「ボーダー点」PDF**（入園最低指数の実績値）も公開している。
例：`r7border.pdf`（令和7年度実績）

- MVP では扱わないが、将来的な機能「ボーダーライン表示（過去の最低指数との比較）」で参照する一次情報
- 自治体によって公開状況が異なるため、v2 実装時に各自治体の公開状況を調査すること

## 公式資料 URL（確認用）

| 自治体  | 公式資料URL                                                                                              |
|------|-------------------------------------------------------------------------------------------------------|
| 那覇市  | https://www.city.naha.okinawa.jp/_res/projects/default_project/_page_/001/002/785/r8kijunnhyo.pdf     |
| 浦添市  | https://www.city.urasoe.lg.jp/ （保育課ページ）                                                              |
| 豊見城市 | https://www.city.tomigusuku.lg.jp/soshiki/4/1021/gyomuannai/1/2/170.html                              |
| 糸満市  | https://www.city.itoman.lg.jp/ （保育課ページ）                                                              |
| 南城市  | https://www.city.nanjo.okinawa.jp/ （保育課ページ）                                                          |
| 南風原町 | https://www.town.haebaru.okinawa.jp/ （保育課ページ）                                                        |
| 与那原町 | https://www.town.yonabaru.okinawa.jp/ （保育課ページ）                                                       |
| 八重瀬町 | https://www.town.yaese.lg.jp/ （保育課ページ）                                                               |

> ⚠️ 上記URLは2026年4月時点。リンク切れがあれば各自治体公式トップから「保育課」を辿り直すこと。

## 自治体別ドキュメント

| 自治体  | 詳細仕様                          | 実装ファイル                          | 対応年度  |
|------|-------------------------------|---------------------------------|-------|
| 那覇市  | [naha-city.md](./naha-city.md) | `lib/scoring/naha_city.dart`     | 令和8年度 |
| 浦添市  | TBD                           | `lib/scoring/urasoe_city.dart`   | TBD   |
| 豊見城市 | TBD                           | `lib/scoring/tomigusuku_city.dart` | TBD |
| 糸満市  | TBD                           | `lib/scoring/itoman_city.dart`   | TBD   |
| 南城市  | TBD                           | `lib/scoring/nanjo_city.dart`    | TBD   |
| 南風原町 | TBD                           | `lib/scoring/haebaru_town.dart`  | TBD   |
| 与那原町 | TBD                           | `lib/scoring/yonabaru_town.dart` | TBD   |
| 八重瀬町 | TBD                           | `lib/scoring/yaese_town.dart`    | TBD   |
