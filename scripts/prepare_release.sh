#!/bin/sh

set -e  # エラーが発生したらスクリプトを終了

echo "🚀 リリースブランチの準備を開始します..."

# 現在のブランチを取得
current_branch=$(git rev-parse --abbrev-ref HEAD)
echo "現在のブランチ: $current_branch"

# package.jsonから現在のバージョンを取得
current_version=$(node -p "require('./package.json').version")
echo "現在のバージョン: $current_version"

# semverを使用してmajorバージョンをインクリメント
new_version=$(npx semver -i major $current_version)
echo "新しいバージョン: $new_version"

# リリースブランチ名を作成
release_branch="release/$new_version"
echo "リリースブランチ名: $release_branch"

# 変更がコミットされていることを確認
if [[ -n $(git status --porcelain) ]]; then
    echo "⚠️  未コミットの変更があります。先にコミットしてください。"
    exit 1
fi

# 1. package.jsonのversionを更新
echo "📝 package.jsonのバージョンを更新中..."
npx json -I -f package.json -e "this.version='$new_version'"

# 2. 新しいリリースブランチを作成してチェックアウト
echo "🌱 リリースブランチを作成中..."
git checkout -b $release_branch

# 3. 更新されたpackage.jsonをコミット
echo "💾 package.jsonの変更をコミット中..."
git add package.json
git commit -m "Bump version to $new_version"

# リモートリポジトリにプッシュ
echo "⬆️  リリースブランチをリモートにプッシュ中..."
git push -u origin $release_branch

# 4. タグを作成してプッシュ
echo "🏷️  タグを作成中..."
git tag -a "v$new_version" -m "Release version $new_version"
git push origin "v$new_version"

echo "✅ リリースブランチの準備が完了しました！"
echo "   ブランチ: $release_branch"
echo "   バージョン: $new_version"
echo "   タグ: v$new_version"
