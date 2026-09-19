#!/usr/bin/env bash
# Create a template instance by copying template/ then repairing platforms + applying config.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE="$ROOT/template"

usage() {
  echo "Usage: $0 <output_dir> [--project-name name] [--org org] [--app-id id] [--app-name name]"
  exit 1
}

OUTPUT="${1:-}"
[[ -n "$OUTPUT" ]] || usage
shift || true

PROJECT_NAME="app_template"
ORG="com.example"
APP_ID=""
APP_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-name) PROJECT_NAME="$2"; shift 2 ;;
    --org) ORG="$2"; shift 2 ;;
    --app-id) APP_ID="$2"; shift 2 ;;
    --app-name) APP_NAME="$2"; shift 2 ;;
    *) echo "Unknown: $1"; usage ;;
  esac
done

if [[ -z "$APP_ID" ]]; then
  APP_ID="${PROJECT_NAME}_local"
fi
if [[ -z "$APP_NAME" ]]; then
  APP_NAME="$PROJECT_NAME"
fi

# CamelCase project segment for default iOS bundle id
IOS_BUNDLE="$(
  PROJECT_NAME="$PROJECT_NAME" ORG="$ORG" ruby -e '
    name = ENV["PROJECT_NAME"].split("_").map { |p| p[0].upcase + p[1..] }.join
    print "#{ENV["ORG"]}.#{name}"
  '
)"
ANDROID_ID="${ORG}.${PROJECT_NAME}"

if [[ -e "$OUTPUT" ]]; then
  echo "Output already exists: $OUTPUT" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"
rsync -a \
  --exclude '.dart_tool' \
  --exclude 'build' \
  --exclude '.idea' \
  "$TEMPLATE/" "$OUTPUT/"

cd "$OUTPUT"
flutter create --project-name "$PROJECT_NAME" --org "$ORG" --platforms=ios,android . >/dev/null
flutter pub get >/dev/null

# Seed instance.config.yaml from example + CLI
PROJECT_NAME="$PROJECT_NAME" ORG="$ORG" APP_NAME="$APP_NAME" APP_ID="$APP_ID" \
IOS_BUNDLE="$IOS_BUNDLE" ANDROID_ID="$ANDROID_ID" \
ruby <<'RUBY'
require "yaml"
raw = File.read("instance.config.yaml.example")
cfg = YAML.safe_load(raw, aliases: true)
cfg["project"]["name"] = ENV.fetch("PROJECT_NAME")
cfg["project"]["org"] = ENV.fetch("ORG")
cfg["project"]["display_name"] = ENV.fetch("APP_NAME")
cfg["identity"]["app_id"] = ENV.fetch("APP_ID")
cfg["platforms"]["ios"]["bundle_id"] = ENV.fetch("IOS_BUNDLE")
cfg["platforms"]["android"]["application_id"] = ENV.fetch("ANDROID_ID")
header = raw[/\A((?:#.*\n)+)/, 1] || ""
File.write("instance.config.yaml", header + YAML.dump(cfg))
puts "seeded instance.config.yaml"
RUBY

if [[ -f "$ROOT/docs/instance-onboarding-checklist.md" ]]; then
  cp "$ROOT/docs/instance-onboarding-checklist.md" ONBOARDING.md
fi

if command -v ruby >/dev/null 2>&1; then
  if ruby -rxcodeproj -e 'puts Xcodeproj::VERSION' >/dev/null 2>&1; then
    ruby "$ROOT/scripts/setup_ios_flavor_build_configs.rb" "$OUTPUT/ios"
  else
    echo "Note: gem install xcodeproj then: ruby $ROOT/scripts/setup_ios_flavor_build_configs.rb $OUTPUT/ios"
  fi
fi

ruby "$ROOT/scripts/apply_instance_config.rb" "$OUTPUT"

dart analyze lib test
echo "Created template instance at $OUTPUT"
echo "1. Edit instance.config.yaml (team_id / secrets), then re-apply:"
echo "   ruby $ROOT/scripts/apply_instance_config.rb $OUTPUT"
echo "2. flutter run --flavor dev --dart-define-from-file=dart_defines.dev.json"
echo "3. Release: see docs/fastlane-cicd.md"
