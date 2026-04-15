# 開発ワークフロー

> 親ドキュメント：[../CLAUDE.md](../CLAUDE.md)

## ブランチ運用

- 作業ブランチ命名規約：`claude/<topic>-<shortid>`
  - 例：`claude/naha-scoring-aP5Yl`、`claude/review-claude-md-cFZXt`
- 1タスク = 1ブランチを基本とし、**固定ブランチを使い回さない**
- 直接 `main` にコミットしない

## 作業完了時の標準フロー（個人開発モード）

1. 作業ブランチでコミット
2. 作業ブランチをリモートへプッシュ（`git push -u origin <branch>`）
3. レビュー不要かつ破壊的影響がないと判断できる場合は `main` にマージ

```bash
# 例：作業完了後
git push -u origin claude/<topic>-<shortid>

# main にマージ（個人開発時のみ）
git checkout main
git pull origin main
git merge --no-ff claude/<topic>-<shortid>
git push origin main

# 作業ブランチへ戻る
git checkout claude/<topic>-<shortid>
```

## 将来コラボ／CI導入時の運用

- `main` をブランチ保護（直接プッシュ禁止、PR必須、CI緑化必須）
- PR レビュー経由でのマージに切り替える
- `flutter test` および `flutter analyze` を CI 必須チェックとする

> ⚠️ 「作業ブランチへのプッシュだけで終わらせない」原則は維持するが、
> マージ前に変更の影響範囲を必ず確認すること。スコアロジック変更時はテスト緑化必須。
