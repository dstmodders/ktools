#!/usr/bin/env bash
#
# Shared helpers for the scripts in this directory.
#
# Source this file after BASE_DIR is defined:
#   source "${BASE_DIR}/common.sh"
#
usage() {
  awk '
    NR==1 && /^#!/ { next }
    /^#/ {
      sub(/^# ?/, "")
      buf = buf ? buf ORS $0 : $0
      next
    }
    buf { exit }
    END {
      if (buf) {
        sub(/[[:space:]]+$/, "", buf)
        print buf
      }
    }
  ' "${BASE_DIR}/$(basename "$0")"
}

_print_style() {
  local mode="$1"
  local color="${2:-}"
  local value="$3"
  local output="${4:-1}"
  local style=''
  local reset=''

  if [ "${NO_COLOR}" = '1' ] || ! [ -t "${output}" ]; then
    printf '%s' "${value}" >&"${output}"
    return
  fi

  case "${mode}" in
    bold) style="$(tput bold 2> /dev/null || true)" ;;
    dim) style="$(tput dim 2> /dev/null || true)" ;;
  esac

  if [ -n "${color}" ]; then
    style="${style}$(tput setaf "${color}" 2> /dev/null || true)"
  fi

  reset="$(tput sgr0 2> /dev/null || true)"
  printf '%s%s%s' "${style}" "${value}" "${reset}" >&"${output}"
}

print_bold_color() {
  _print_style 'bold' "$1" "$2" "${3:-1}"
}

print_dim() {
  _print_style 'dim' '' "$1" "${2:-1}"
}

print_dim_color() {
  _print_style 'dim' "$1" "$2" "${3:-1}"
}

print_error() {
  local message="$1"
  print_bold_color 1 "error: ${message}" 2
  printf '\n' >&2
}

die() {
  local message="$1"
  print_error "${message}"
  exit 1
}

print_separator() {
  local colors=''
  local color=6
  local dim=''
  local terminal="${TERM:-}"

  if [ "${NO_COLOR}" = '1' ] || ! [ -t 1 ]; then
    print_dim '---'
    printf '\n'
    return
  fi

  if [ "${TERM_PROGRAM:-}" != 'Apple_Terminal' ]; then
    dim="$(tput dim 2> /dev/null || true)"
    if [ -n "${dim}" ]; then
      print_dim '---'
      printf '\n'
      return
    fi
  fi

  case "${terminal}" in
    ansi | cygwin | linux | screen* | tmux* | vt100* | xterm* | rxvt* | konsole* | alacritty | kitty | foot*)
      printf '\033[2m---\033[0m\n'
      return
      ;;
  esac
  if [ "${TERM_PROGRAM:-}" = 'Apple_Terminal' ]; then
    printf '\033[2m---\033[0m\n'
    return
  fi

  colors="$(tput colors 2> /dev/null || true)"
  if [[ "${colors}" =~ ^[0-9]+$ ]] && [ "${colors}" -ge 16 ]; then
    color=8
  fi
  _print_style '' "${color}" '---'
  printf '\n'
}

complete() {
  local color="$1"
  local message="$2"
  print_separator
  print_bold_color "${color}" "${message}"
  printf '\n'
  exit 0
}

# shellcheck disable=SC2329
interrupt() {
  printf '\n'
  print_separator
  print_bold_color 1 'Interrupted'
  printf '\n'
  exit 130
}

print_step() {
  local message="$1"
  local value="${2:-}"

  printf -- '--> %s' "${message}"
  if [ -n "${value}" ]; then
    printf ': '
    print_bold_color 7 "${value}"
  fi
}

print_step_dotted() {
  local message="$1"
  local value="${2:-}"

  print_step "${message}" "${value}"
  printf '... '
}

print_step_success() {
  local value="${1:-Success}"
  print_bold_color 2 "${value}"
  printf '\n'
}

print_step_skipped() {
  local value="${1:-Skipped}"
  print_bold_color 3 "${value}"
  printf '\n'
}

print_step_failed() {
  local value="${1:-Failed}"
  print_bold_color 1 "${value}"
  printf '\n'
}

is_installed() {
  command -v "$1" > /dev/null 2>&1
}

require_cmds() {
  local cmd
  for cmd in "$@"; do
    if ! is_installed "${cmd}"; then
      if [ "${cmd}" = 'docker' ]; then
        die 'Docker CLI is not installed'
      fi
      die "${cmd} is required"
    fi
  done
}
