#!/bin/bash

# ==============================================================================
# NocoBase Master Agent Kit - Universal 1-Click Installer
# © 2026 BASANCORP Enterprise Solutions
# Hỗ trợ: Hermes Agent, Claude Code, Cursor, Windsurf, Antigravity, OpenCode, Cline
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-$(pwd)}"
IS_HERMES=false

# Kiểm tra cờ --hermes
for arg in "$@"; do
  if [ "$arg" == "--hermes" ]; then
    IS_HERMES=true
  fi
done

echo "🚀 Bắt đầu cài đặt NocoBase Master Agent Kit..."

if [ "$IS_HERMES" = true ] || [ -d "$HOME/.hermes" ]; then
  HERMES_DIR="$HOME/.hermes/skills/nocobase"
  echo "🤖 Phát hiện môi trường Hermes Agent. Đang cài đặt vào: $HERMES_DIR"
  mkdir -p "$HERMES_DIR"
  cp -R "$SCRIPT_DIR/skills/"* "$HERMES_DIR/"
  cp "$SCRIPT_DIR/hermes.json" "$HERMES_DIR/"
  cp "$SCRIPT_DIR/manifest.json" "$HERMES_DIR/"
  cp "$SCRIPT_DIR/AGENTS.md" "$HERMES_DIR/"
  echo "✅ Đã đồng bộ 25 kỹ năng vào Hermes Agent Ecosystem!"
fi

if [ "$TARGET_DIR" != "--hermes" ]; then
  echo "📁 Cài đặt vào thư mục dự án: $TARGET_DIR"
  # 1. Tạo các thư mục skills
  mkdir -p "$TARGET_DIR/.agents/skills"
  mkdir -p "$TARGET_DIR/.claude/skills"

  # 2. Copy toàn bộ 25 skills
  echo "📦 Đang nạp 25 kỹ năng NocoBase & BasanCorp Enterprise..."
  cp -R "$SCRIPT_DIR/skills/"* "$TARGET_DIR/.agents/skills/"
  cp -R "$SCRIPT_DIR/skills/"* "$TARGET_DIR/.claude/skills/"

  # 3. Copy các file điều phối hệ thống & Hermes manifest
  echo "🧠 Đang nạp Não bộ điều phối AGENTS.md, hermes.json và các adapter..."
  cp "$SCRIPT_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md"
  cp "$SCRIPT_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
  cp "$SCRIPT_DIR/.cursorrules" "$TARGET_DIR/.cursorrules"
  cp "$SCRIPT_DIR/.windsurfrules" "$TARGET_DIR/.windsurfrules"
  cp "$SCRIPT_DIR/hermes.json" "$TARGET_DIR/hermes.json"
  cp "$SCRIPT_DIR/manifest.json" "$TARGET_DIR/manifest.json"
fi

echo ""
echo "=============================================================================="
echo "✅ CÀI ĐẶT THÀNH CÔNG NOCOBASE MASTER AGENT KIT (HERMES COMPLIANT)!"
echo "=============================================================================="
echo "• 25 Kỹ năng chuẩn hóa Hermes: $TARGET_DIR/.agents/skills/"
echo "• Hermes Manifest:             $TARGET_DIR/hermes.json"
echo "• Não bộ điều phối:            $TARGET_DIR/AGENTS.md"
echo "• Tương thích 100%:            Hermes Agent, Claude Code, Cursor, Windsurf, OpenCode"
echo ""
echo "👉 Hướng dẫn kích hoạt:"
echo "   - Nếu dùng Hermes Agent:    'hermes skill list' hoặc chạy agent bình thường."
echo "   - Nếu dùng Claude Code:     Gõ 'claude' trong thư mục dự án."
echo "   - Nếu dùng Cursor/Windsurf: Mở thư mục dự án và bắt đầu chat với AI."
echo "   - Nếu dùng Custom GPTs:     Copy nội dung file AGENTS.md làm System Prompt."
echo "=============================================================================="
