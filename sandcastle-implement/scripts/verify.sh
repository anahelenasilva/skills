#!/usr/bin/env bash
set -euo pipefail

echo "▶ Running typecheck..."
pnpm run typecheck

echo "▶ Running tests..."
pnpm run test

echo "✅ Verification passed."
