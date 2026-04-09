#!/usr/bin/env bash
# shellcheck shell=bash

# This script is intended to be sourced:
#   source scripts/dev-env.sh

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "error: source this script instead of executing it" >&2
  echo "usage: source scripts/dev-env.sh" >&2
  exit 1
fi

set -a

if [ -n "${BASH_SOURCE[0]:-}" ]; then
  script_path="${BASH_SOURCE[0]}"
elif [ -n "${ZSH_VERSION:-}" ]; then
  script_path="${(%):-%N}"
else
  script_path="$0"
fi

ROOT_DIR="$(cd "$(dirname "${script_path}")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"

# Defaults
GR4_ENV_NAME="${GR4_ENV_NAME:-local}"
GR4_CONTROL_PLANE_PORT="${GR4_CONTROL_PLANE_PORT:-8080}"
GR4_STUDIO_PORT="${GR4_STUDIO_PORT:-5173}"
GR4_SRC_DIR="${GR4_SRC_DIR:-src}"
GR4_BUILD_DIR="${GR4_BUILD_DIR:-build}"
GR4_PREFIX_DIR="${GR4_PREFIX_DIR:-install}"
GR4_LLVM_ROOT="${GR4_LLVM_ROOT:-}"
GR4_CC="${GR4_CC:-}"
GR4_CXX="${GR4_CXX:-}"
GR4_PKGCONF="${GR4_PKGCONF:-pkgconf}"
GR4_LOG_LEVEL="${GR4_LOG_LEVEL:-info}"
GR4_DEBUG="${GR4_DEBUG:-0}"

if [ -f "${ENV_FILE}" ]; then
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
fi

if [ -z "${GR4_CONTROL_PLANE_URL:-}" ]; then
  GR4_CONTROL_PLANE_URL="http://127.0.0.1:${GR4_CONTROL_PLANE_PORT}"
fi

export GR4_ROOT_DIR="${ROOT_DIR}"
export GR4_SRC_PATH="${ROOT_DIR}/${GR4_SRC_DIR}"
export GR4_BUILD_PATH="${ROOT_DIR}/${GR4_BUILD_DIR}"
export GR4_PREFIX_PATH="${ROOT_DIR}/${GR4_PREFIX_DIR}"
export GR4_PREFIX="${GR4_PREFIX_PATH}"

mkdir -p "${GR4_SRC_PATH}" "${GR4_BUILD_PATH}" "${GR4_PREFIX_PATH}" "${ROOT_DIR}/var/logs" "${ROOT_DIR}/var/run"

prepend_path() {
  local dir="$1"
  case ":${PATH}:" in
    *":${dir}:"*) ;;
    *) PATH="${dir}${PATH:+:${PATH}}" ;;
  esac
}

prepend_flags() {
  local var_name="$1"
  local flag="$2"
  local current=""

  eval "current=\${${var_name}:-}"
  case " ${current} " in
    *" ${flag} "*) ;;
    *) eval "export ${var_name}=\"${flag}\${current:+ \${current}}\"" ;;
  esac
}

if [ -n "${GR4_LLVM_ROOT}" ] && [ -d "${GR4_LLVM_ROOT}/bin" ]; then
  prepend_path "${GR4_LLVM_ROOT}/bin"
fi

export PATH

if [ -n "${GR4_CC}" ]; then
  if [ -n "${GR4_LLVM_ROOT}" ] && [ "${GR4_CC}" = "clang-20" ] && [ -x "${GR4_LLVM_ROOT}/bin/clang" ]; then
    GR4_CC="${GR4_LLVM_ROOT}/bin/clang"
  fi
  export CC="${GR4_CC}"
  export CMAKE_C_COMPILER="${CC}"
else
  unset CC CMAKE_C_COMPILER
fi

if [ -n "${GR4_CXX}" ]; then
  if [ -n "${GR4_LLVM_ROOT}" ] && [ "${GR4_CXX}" = "clang++-20" ] && [ -x "${GR4_LLVM_ROOT}/bin/clang++" ]; then
    GR4_CXX="${GR4_LLVM_ROOT}/bin/clang++"
  fi
  export CXX="${GR4_CXX}"
  export CMAKE_CXX_COMPILER="${CXX}"
else
  unset CXX CMAKE_CXX_COMPILER
fi

export PKGCONF="${GR4_PKGCONF}"
export PKG_CONFIG="${PKGCONF}"

export PATH="${GR4_PREFIX_PATH}/bin:${PATH}"

if [ "$(uname -s)" = "Darwin" ] && command -v xcrun >/dev/null 2>&1; then
  sdkroot="${SDKROOT:-$(xcrun --show-sdk-path 2>/dev/null || true)}"
  sdkver="$(xcrun --show-sdk-version 2>/dev/null || true)"

  if [ -n "${sdkroot}" ]; then
    export SDKROOT="${sdkroot}"
    export CMAKE_OSX_SYSROOT="${CMAKE_OSX_SYSROOT:-${sdkroot}}"

    if [ -z "${MACOSX_DEPLOYMENT_TARGET:-}" ] && [ -n "${sdkver}" ]; then
      export MACOSX_DEPLOYMENT_TARGET="${sdkver%.*}.0"
    fi
    if [ -z "${CMAKE_OSX_DEPLOYMENT_TARGET:-}" ] && [ -n "${MACOSX_DEPLOYMENT_TARGET:-}" ]; then
      export CMAKE_OSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET}"
    fi

    prepend_flags CFLAGS "-isysroot ${sdkroot}"
    prepend_flags CXXFLAGS "-isysroot ${sdkroot}"
    prepend_flags CPPFLAGS "-isysroot ${sdkroot}"
    prepend_flags LDFLAGS "-Wl,-syslibroot,${sdkroot}"
  fi

  if [ -n "${GR4_LLVM_ROOT}" ]; then
    # Homebrew libc++ gates some newer APIs, including floating-point
    # std::from_chars, behind availability annotations on macOS.
    prepend_flags CPPFLAGS "-D_LIBCPP_DISABLE_AVAILABILITY"
    prepend_flags LDFLAGS "-L${GR4_LLVM_ROOT}/lib/c++"
    prepend_flags LDFLAGS "-L${GR4_LLVM_ROOT}/lib/unwind"
    prepend_flags LDFLAGS "-Wl,-rpath,${GR4_LLVM_ROOT}/lib/c++"
    prepend_flags LDFLAGS "-Wl,-rpath,${GR4_LLVM_ROOT}/lib/unwind"
    prepend_flags LDFLAGS "-lunwind"
  fi
fi

export CMAKE_PREFIX_PATH="${GR4_PREFIX_PATH}${CMAKE_PREFIX_PATH:+:${CMAKE_PREFIX_PATH}}"
export PKG_CONFIG_PATH="${GR4_PREFIX_PATH}/lib/pkgconfig:${GR4_PREFIX_PATH}/lib64/pkgconfig:${GR4_PREFIX_PATH}/share/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}}"
export LD_LIBRARY_PATH="${GR4_PREFIX_PATH}/lib:${GR4_PREFIX_PATH}/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
export DYLD_LIBRARY_PATH="${GR4_PREFIX_PATH}/lib:${GR4_PREFIX_PATH}/lib64${DYLD_LIBRARY_PATH:+:${DYLD_LIBRARY_PATH}}"
export PYTHONPATH="${GR4_PREFIX_PATH}/lib/python3/site-packages${PYTHONPATH:+:${PYTHONPATH}}"
export GNURADIO4_PLUGIN_DIRECTORIES="${GR4_PREFIX_PATH}/lib${GNURADIO4_PLUGIN_DIRECTORIES:+:${GNURADIO4_PLUGIN_DIRECTORIES}}"

set +a

echo "Loaded gr4-dev environment (${GR4_ENV_NAME})"
echo "ROOT=${GR4_ROOT_DIR}"
echo "PREFIX=${GR4_PREFIX_PATH}"
