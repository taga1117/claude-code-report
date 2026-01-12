import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    // テスト環境
    environment: "node",

    // グローバルAPIを有効化（describe, it, expect等）
    globals: true,

    // テストファイルのパターン
    include: ["src/**/*.{test,spec}.{js,ts}", "tests/**/*.{test,spec}.{js,ts}"],

    // 除外パターン
    exclude: ["node_modules", "dist"],

    // カバレッジ設定
    coverage: {
      provider: "v8",
      reporter: ["text", "json", "html"],
      reportsDirectory: "./coverage",
      include: ["src/**/*.ts"],
      exclude: ["src/**/*.{test,spec}.ts", "src/**/*.d.ts"],
    },

    // タイムアウト設定
    testTimeout: 10000,

    // セットアップファイル
    setupFiles: ["./tests/setup.ts"],
  },
});
