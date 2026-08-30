#!/usr/bin/env bash
# 一键构建 prod IPA 并上传到 App Store Connect（TestFlight）。
#
# 用法:
#   ./scripts/upload_app_store.sh              # 上传 TestFlight（默认）
#   ./scripts/upload_app_store.sh --release    # 上传到 App Store（不自动提审）
#   SKIP_MATCH=true ./scripts/upload_app_store.sh   # 跳过 match，用本机 Xcode 签名（默认）
#   SKIP_MATCH=false ./scripts/upload_app_store.sh  # 使用 match 证书仓库
#
# 首次配置：复制 .env.example → .env，填入 Apple Team / App Store Connect API Key。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LANE="beta"
# 默认跳过 match：MATCH_GIT_URL 需指向独立证书仓库且配置 SSH；否则用本机 Xcode 自动签名
export SKIP_MATCH="${SKIP_MATCH:-true}"

ensure_ruby() {
  if [[ -f "$ROOT/.ruby-version" ]] && command -v mise >/dev/null 2>&1; then
    eval "$(mise activate bash)"
    mise install -q 2>/dev/null || true
  elif [[ -f "$ROOT/.ruby-version" ]] && command -v rbenv >/dev/null 2>&1; then
    eval "$(rbenv init - bash)"
  fi

  local ruby_ver bundle_path ruby_bin
  ruby_bin="$(dirname "$(command -v ruby)")"
  export PATH="${ruby_bin}:${PATH}"

  ruby_ver="$(ruby -e 'print RUBY_VERSION' 2>/dev/null || echo unknown)"
  bundle_path="$(command -v bundle || true)"

  if [[ "$ruby_ver" == 2.6.* ]] || [[ "$bundle_path" == /usr/bin/bundle ]]; then
    echo "错误：当前使用系统 Ruby ${ruby_ver}（${bundle_path}）" >&2
    echo "fastlane 需要 Ruby >= 3.0。请在本目录执行：" >&2
    echo "  mise install && eval \"\$(mise activate bash)\" && bundle install" >&2
    exit 1
  fi

  if ! command -v pod >/dev/null 2>&1; then
    echo "安装 CocoaPods（mise Ruby ${ruby_ver}）..."
    gem install cocoapods -N
  fi

  echo "Ruby ${ruby_ver} (${bundle_path})"
  echo "CocoaPods $(pod --version) ($(command -v pod))"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --release) LANE="release" ;;
    -h|--help)
      sed -n '2,12p' "$0"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

cd "$ROOT"

ensure_ruby

if [[ ! -f .env ]]; then
  echo "缺少 .env — 请复制 .env.example 并填入 Apple / App Store Connect 凭据" >&2
  exit 1
fi

echo "== 1/3 同步 App Icon =="
bash scripts/sync_app_icons.sh

echo "== 2/3 检查 Ruby 依赖 =="
if ! bundle check >/dev/null 2>&1; then
  bundle install
fi

echo "== 3/3 Fastlane ${LANE}（SKIP_MATCH=${SKIP_MATCH}）==="
cd ios
bundle exec fastlane "$LANE"

echo ""
echo "✓ 上传完成。请到 App Store Connect 查看处理状态："
echo "  https://appstoreconnect.apple.com/apps"
