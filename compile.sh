#!/usr/bin/env bash
set -euo pipefail

# =========================
# Configuración de toolchain
# =========================
AS="aarch64-linux-gnu-as"
LD="aarch64-linux-gnu-ld"
QEMU="qemu-aarch64"

# Include de archivos (para .include "macros.s", etc.)
ASFLAGS="-I ./src"

BUILD_DIR="./build"
SRC_DIR="./src"

mode="${1:-build}"

# Colores (opcional)
green() { printf "\033[1;32m%s\033[0m\n" "$*"; }
yellow() { printf "\033[1;33m%s\033[0m\n" "$*"; }
red() { printf "\033[1;31m%s\033[0m\n" "$*"; }

ensure_build_dir() {
  mkdir -p "$BUILD_DIR"
}

assemble_all() {
  green "🔧 Modo: Compilar código fuente..."
  ensure_build_dir
  yellow "🛠️  Ensamblando Archivos..."

  # Toma todos los .s menos macros.s (las macros solo se incluyen)
  mapfile -t sources < <(find "$SRC_DIR" -maxdepth 1 -type f -name "*.s" ! -name "macros.s" | sort)

  if [[ ${#sources[@]} -eq 0 ]]; then
    red "❌ No hay archivos .s para ensamblar en $SRC_DIR"
    exit 1
  fi

  for s in "${sources[@]}"; do
    obj="$BUILD_DIR/$(basename "${s%.s}").o"
    base="$(basename "$s")"
    echo "  $base -> $(basename "$obj")"
    $AS $ASFLAGS -o "$obj" "$s"
  done
  green "✅ Ensamblado completado."

  yellow "🔗 Enlazando objetos..."
  # Enlaza todos los .o encontrados
  mapfile -t objs < <(find "$BUILD_DIR" -maxdepth 1 -type f -name "*.o" | sort)

  # Recomendado: exigir main.o para tener punto de entrada _start
  if [[ ! -f "$BUILD_DIR/main.o" ]]; then
    red "❌ Falta $BUILD_DIR/main.o (asegúrate de tener src/main.s con etiqueta _start)"
    exit 1
  fi

  $LD -o "$BUILD_DIR/main" "${objs[@]}"
  green "✅ Enlace completado: $BUILD_DIR/main"
}

run_prog() {
  if [[ ! -x "$BUILD_DIR/main" ]]; then
    red "❌ No existe $BUILD_DIR/main. Compila primero:  bash compile.sh build"
    exit 1
  fi
  yellow "▶️  Ejecutando con QEMU..."
  exec $QEMU "$BUILD_DIR/main"
}

clean_all() {
  yellow "🧹 Limpiando build..."
  rm -rf "$BUILD_DIR"
  green "✅ Limpieza completada."
}

case "$mode" in
  build) assemble_all ;;
  run)   run_prog ;;
  clean) clean_all ;;
  *)
    echo "Uso: bash compile.sh [build|run|clean]"
    exit 1
    ;;
esac