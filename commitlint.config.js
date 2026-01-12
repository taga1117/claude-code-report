export default {
  extends: ["@commitlint/config-conventional"],
  rules: {
    // コミットメッセージのタイプ
    "type-enum": [
      2,
      "always",
      [
        "feat", // 新機能
        "fix", // バグ修正
        "docs", // ドキュメント
        "style", // コードスタイル（動作に影響しない）
        "refactor", // リファクタリング
        "perf", // パフォーマンス改善
        "test", // テスト
        "chore", // ビルド、補助ツール
        "revert", // コミット取り消し
        "ci", // CI設定
      ],
    ],
    // 件名の最大長
    "subject-max-length": [2, "always", 100],
  },
};
