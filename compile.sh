#!/usr/bin/env bash

# =============================================
# COMPILADOR AES-128 ARM64 - PROYECTO UNIVERSIDAD
# =============================================

# Configuración de parámetros base
AS="aarch64-linux-gnu-as"
LD="aarch64-linux-gnu-ld"
ASFLAGS="-g"                # Incluye símbolos de depuración
LDFLAGS="-static -g"        # Enlace estático con debug
SRC_DIR="./src"             # Carpeta de código fuente
BUILD_DIR="./build"         # Carpeta para archivos .o
OUTPUT="aes128"             # Nombre del ejecutable final

# =============================================
# FUNCIONES DE UTILIDAD
# =============================================

print_status() {
    echo "📦 $1"
}

print_error() {
    echo "❌ $1"
}

print_success() {
    echo "✅ $1"
}

# =============================================
# MODO LIMPIEZA
# =============================================

if [[ "$1" == "clean" ]]; then
    print_status "Limpiando build..."
    rm -rf "$BUILD_DIR"
    if [[ -f "./$OUTPUT" ]]; then
        rm "./$OUTPUT"
    fi
    print_success "Limpieza completada"
    exit 0
fi

# =============================================
# MODO COMPILACIÓN
# =============================================

print_status "Iniciando compilación AES-128 ARM64..."

# Crear directorio build si no existe
if [[ ! -d "$BUILD_DIR" ]]; then
    print_status "Creando directorio build..."
    mkdir -p "$BUILD_DIR"
    if [[ $? -ne 0 ]]; then
        print_error "No se pudo crear directorio build"
        exit 1
    fi
fi

# =============================================
# ENSAMBLAR ARCHIVOS
# =============================================

print_status "Ensamblando archivos..."

# Lista de archivos a compilar (en orden de dependencia)
archivos=(
    "constants.s"
    "macros.s" 
    "utils.s"
    "addRoundKey.s"
    "byteSub.s"
    "shiftRows.s"
    "mixColumns.s"
    "keyExpansion.s"
    "main.s"
)

# Ensamblar cada archivo
for archivo in "${archivos[@]}"; do
    if [[ -f "$SRC_DIR/$archivo" ]]; then
        print_status "  $archivo -> ${archivo%.s}.o"
        $AS $ASFLAGS -I "$SRC_DIR" -o "$BUILD_DIR/${archivo%.s}.o" "$SRC_DIR/$archivo"
        if [ $? -ne 0 ]; then
            print_error "Error ensamblando $archivo"
            exit 1
        fi
    else
        print_error "Archivo no encontrado: $SRC_DIR/$archivo"
        exit 1
    fi
done

print_success "Ensamblado completado"

# =============================================
# ENLAZAR OBJETOS
# =============================================

print_status "Enlazando objetos..."

# Crear lista de objetos
OBJ_FILES=""
for archivo in "${archivos[@]}"; do
    OBJ_FILES="$OBJ_FILES $BUILD_DIR/${archivo%.s}.o"
done

# Enlazar
$LD $LDFLAGS $OBJ_FILES -o "$BUILD_DIR/$OUTPUT"

if [ $? -ne 0 ]; then
    print_error "Error enlazando objetos"
    exit 1
fi

print_success "Enlazado completado: $OUTPUT"
print_success "Ejecutable listo en: $BUILD_DIR/$OUTPUT"

# =============================================
# OPCIONES DE EJECUCIÓN
# =============================================

if [[ "$1" == "exec" ]]; then
    print_status "Ejecutando programa..."
    qemu-aarch64 "$BUILD_DIR/$OUTPUT"
    
elif [[ "$1" == "debug" ]]; then
    print_status "Iniciando depuración..."
    echo "🔍 Iniciando QEMU en puerto 1234..."
    qemu-aarch64 -g 1234 "$BUILD_DIR/$OUTPUT" &
    sleep 2
    echo "Iniciando GDB..."
    gdb-multiarch -q "$BUILD_DIR/$OUTPUT" -ex "target remote localhost:1234" -ex "layout split"
    
elif [[ "$1" == "test" ]]; then
    print_status "Ejecutando prueba básica..."
    qemu-aarch64 "$BUILD_DIR/$OUTPUT"
fi