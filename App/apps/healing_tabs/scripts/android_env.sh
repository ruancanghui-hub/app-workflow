#!/usr/bin/env bash
# Shared Android / Java env for healing_tabs run scripts.
# Safe to source multiple times.

_HEALING_JDK="${HEALING_TABS_JAVA_HOME:-$HOME/.jdks/jdk-17.0.20.1+1/Contents/Home}"
_HEALING_ANDROID_SDK="${HEALING_TABS_ANDROID_HOME:-$HOME/homebrew/share/android-commandlinetools}"

if [[ -d "$_HEALING_JDK" ]]; then
  export JAVA_HOME="$_HEALING_JDK"
  case ":$PATH:" in
    *":$JAVA_HOME/bin:"*) ;;
    *) export PATH="$JAVA_HOME/bin:$PATH" ;;
  esac
fi

if [[ -d "$_HEALING_ANDROID_SDK" ]]; then
  export ANDROID_HOME="$_HEALING_ANDROID_SDK"
  export ANDROID_SDK_ROOT="$ANDROID_HOME"
  case ":$PATH:" in
    *":$ANDROID_HOME/platform-tools:"*) ;;
    *) export PATH="$ANDROID_HOME/platform-tools:$PATH" ;;
  esac
fi
