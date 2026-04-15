# 自治体別スコアリングルール

> 親ドキュメント：[../../CLAUDE.md](../../CLAUDE.md)
> 関連：[../architecture.md](../architecture.md)

## 実装方針

各自治体ファイルは同じ `ScoringRule` を継承して実装する。
指数PDFは各自治体の公式サイトから取得し、`sourceUrl` および `fiscalYear` プロパティで明示する。

> ⚠️ 那覇市以外の指数表は実装前に必ず各自治体の公式PDFを確認すること。
> 配点スケールが自治体ごとに異なるため、コピーせず個別に実装する。

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
