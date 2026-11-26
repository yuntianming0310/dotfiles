#!/usr/bin/env bash
set -euo pipefail

# Catppuccin Mocha 柔和文字配色
RST=$'\033[0m'
C_BLUE=$'\033[38;2;137;180;250m'
C_TEXT=$'\033[38;2;205;214;244m'
C_SUBTEXT=$'\033[38;2;166;173;200m'
C_OVERLAY=$'\033[38;2;108;112;134m'
C_SURFACE=$'\033[38;2;88;91;112m'
C_GREEN=$'\033[38;2;166;227;161m'
C_YELLOW=$'\033[38;2;249;226;175m'
C_RED=$'\033[38;2;243;139;168m'
C_TEAL=$'\033[38;2;148;226;213m'

PAYLOAD="$(cat)"

if [ -z "$PAYLOAD" ] || ! command -v jq >/dev/null 2>&1; then
  printf '%sctx%s %s--%s  %s|%s  %s--%s\n' \
    "$C_SUBTEXT" "$RST" "$C_OVERLAY" "$RST" \
    "$C_SURFACE" "$RST" \
    "$C_OVERLAY" "$RST"
  exit 0
fi

format_tokens() {
  LC_NUMERIC=C awk -v n="$1" 'BEGIN {
    if (n >= 1000000) {
      printf "%.1fM", n / 1000000;
    } else if (n >= 100000) {
      printf "%.0fk", n / 1000;
    } else if (n >= 1000) {
      printf "%.1fk", n / 1000;
    } else {
      printf "%d", n;
    }
  }'
}

format_duration() {
  local secs="$1"
  if [ "$secs" -ge 86400 ]; then
    printf '%dd %dh' $((secs / 86400)) $(((secs % 86400) / 3600))
  elif [ "$secs" -ge 3600 ]; then
    printf '%dh %dm' $((secs / 3600)) $(((secs % 3600) / 60))
  elif [ "$secs" -ge 60 ]; then
    printf '%dm' $((secs / 60))
  else
    printf '%ds' "$secs"
  fi
}

short_label() {
  local raw="$1"
  # 去掉 gemini- / 3p- 前缀（当前模型已在默认状态栏右侧显示）
  raw="${raw#gemini-}"
  raw="${raw#3p-}"
  case "$raw" in
    weekly) printf 'wk' ;;
    daily)  printf '1d' ;;
    *)      printf '%s' "$raw" ;;
  esac
}

# 单次 jq 提取上下文窗口，并按当前模型自动筛选对应配额桶（Gemini -> gemini-*，Claude/GPT -> 3p-*）
PARSED="$(printf '%s' "$PAYLOAD" | jq -r '
  (
    [
      "CTX",
      (if (.context_window.context_window_size | type) == "number" then (.context_window.context_window_size | floor | tostring) else "0" end),
      (if (.context_window.used_percentage | type) == "number" then (.context_window.used_percentage | tostring) else "" end),
      (if (.context_window.total_input_tokens | type) == "number" then (.context_window.total_input_tokens | floor | tostring) else "0" end),
      (if (.context_window.total_output_tokens | type) == "number" then (.context_window.total_output_tokens | floor | tostring) else "0" end),
      ""
    ] | join("|")
  ),
  (
    ((.model.id // .model.display_name // "") | ascii_downcase) as $m
    | ((.quota // {}) | if type == "object" then to_entries else [] end) as $all
    | (
        if ($m | contains("gemini")) then
          ($all | map(select(.key | startswith("gemini"))))
        elif ($m != "") then
          ($all | map(select(.key | startswith("3p"))))
        else
          $all
        end
      ) as $matched
    | (if ($matched | length) > 0 then $matched else $all end)
    | sort_by(.key)
    | .[]
    | [
        "QUOTA",
        .key,
        (if (.value.remaining_fraction | type) == "number" then (.value.remaining_fraction | tostring) else "" end),
        (if (.value.remaining_amount | type) == "number" then (.value.remaining_amount | tostring) else "" end),
        (if (.value.reset_in_seconds | type) == "number" then (.value.reset_in_seconds | floor | tostring) else "" end),
        (if .value.disabled == true then "true" else "false" end)
      ]
    | join("|")
  )
' 2>/dev/null || true)"

CTX_OUT="${C_SUBTEXT}ctx${RST} ${C_OVERLAY}--${RST}"
QUOTA_SEGMENTS=()

while IFS='|' read -r kind f1 f2 f3 f4 f5; do
  if [ "$kind" = "CTX" ]; then
    ctx_size="${f1:-0}"
    used_pct="${f2:-}"
    in_tok="${f3:-0}"
    out_tok="${f4:-0}"

    if [ "$ctx_size" -gt 0 ] 2>/dev/null; then
      if [ -n "$used_pct" ]; then
        used_tok="$(LC_NUMERIC=C awk -v sz="$ctx_size" -v p="$used_pct" 'BEGIN {
          u = int(sz * p / 100 + 0.5);
          if (u < 0) u = 0;
          if (u > sz) u = sz;
          printf "%d", u;
        }')"
        ctx_pct_int="$(LC_NUMERIC=C awk -v p="$used_pct" 'BEGIN {
          v = int(p + 0.5);
          if (v < 0) v = 0;
          if (v > 100) v = 100;
          printf "%d", v;
        }')"
        ctx_pct_fmt="$(LC_NUMERIC=C awk -v p="$used_pct" 'BEGIN {
          if (p > 0 && p < 10) printf "%.1f", p;
          else printf "%.0f", p;
        }')"
      else
        used_tok=$((in_tok + out_tok))
        ctx_pct_int=$(( used_tok * 100 / ctx_size ))
        ctx_pct_fmt="$ctx_pct_int"
      fi

      if [ "$ctx_pct_int" -ge 85 ]; then
        ctx_color="$C_RED"
      elif [ "$ctx_pct_int" -ge 60 ]; then
        ctx_color="$C_YELLOW"
      else
        ctx_color="$C_BLUE"
      fi

      used_str="$(format_tokens "$used_tok")"
      total_str="$(format_tokens "$ctx_size")"
      CTX_OUT="${C_SUBTEXT}ctx${RST} ${ctx_color}${used_str}${RST}${C_OVERLAY}/${RST}${C_TEXT}${total_str}${RST} ${C_OVERLAY}(${ctx_pct_fmt}%)${RST}"
    fi
  elif [ "$kind" = "QUOTA" ]; then
    bucket="$f1"
    frac="$f2"
    amount="$f3"
    reset_sec="$f4"
    disabled="$f5"
    [ -z "$bucket" ] && continue

    label="$(short_label "$bucket")"

    if [ -n "$frac" ]; then
      pct_fmt="$(LC_NUMERIC=C awk -v f="$frac" 'BEGIN {
        p = f * 100;
        if (p < 0) p = 0;
        if (p > 100) p = 100;
        if (p > 0 && p < 10) printf "%.1f", p;
        else printf "%.0f", p;
      }')"
      pct_int="$(LC_NUMERIC=C awk -v f="$frac" 'BEGIN {
        p = int(f * 100 + 0.5);
        if (p < 0) p = 0;
        if (p > 100) p = 100;
        printf "%d", p;
      }')"

      if [ "$disabled" = "true" ] || [ "$pct_int" -lt 20 ]; then
        q_color="$C_RED"
      elif [ "$pct_int" -lt 50 ]; then
        q_color="$C_YELLOW"
      else
        q_color="$C_GREEN"
      fi

      seg="${C_SUBTEXT}${label}${RST} ${q_color}${pct_fmt}%${RST}"
    elif [ -n "$amount" ]; then
      q_color="$C_TEAL"
      [ "$disabled" = "true" ] && q_color="$C_RED"
      seg="${C_SUBTEXT}${label}${RST} ${q_color}${amount}${RST}"
    else
      continue
    fi

    if [ -n "$reset_sec" ] && [ "$reset_sec" -gt 0 ] 2>/dev/null; then
      seg+=" ${C_OVERLAY}($(format_duration "$reset_sec"))${RST}"
    fi

    QUOTA_SEGMENTS+=("$seg")
  fi
done <<< "$PARSED"

if [ "${#QUOTA_SEGMENTS[@]}" -eq 0 ]; then
  QUOTA_OUT="${C_OVERLAY}--${RST}"
else
  QUOTA_OUT=""
  for i in "${!QUOTA_SEGMENTS[@]}"; do
    [ "$i" -gt 0 ] && QUOTA_OUT+=" ${C_SURFACE}·${RST} "
    QUOTA_OUT+="${QUOTA_SEGMENTS[$i]}"
  done
fi

printf '%s  %s|%s  %s\n' "$CTX_OUT" "$C_SURFACE" "$RST" "$QUOTA_OUT"
