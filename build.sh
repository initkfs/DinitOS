#!/usr/bin/env bash
#script name
scriptName="$(basename "$([[ -L "$0" ]] && readlink "$0" || echo "$0")")"
if [[ -z $scriptName ]]; then
  echo "Error, script name is empty. Exit" >&2
  exit 1
fi
#script directory
_source="${BASH_SOURCE[0]}"
while [[ -h "$_source" ]]; do
  _dir="$( cd -P "$( dirname "$_source" )" && pwd )"
  _source="$(readlink "$_source")"
  [[ $_source != /* ]] && _source="$_dir/$_source"
done
scriptDir="$( cd -P "$( dirname "$_source" )" && pwd )"
if [[ ! -d $scriptDir ]]; then
  echo "$scriptName error: incorrect script source directory $scriptDir, exit." >&2
  exit 1
fi
#Start script

buildDir=$scriptDir/build
sourceDir=$scriptDir/src
bootSourceDir=$sourceDir/boot/riscv

bootFile=$buildDir/boot
kernelFile=$buildDir/kernel
kernelElf=${kernelFile}.elf
kernelBin=${kernelFile}.bin

POSITIONAL_ARGS=()
buildType=debug
archType=r32
isRelease=false
isGdb=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -b|--build)
      buildType="$2"
      shift
      shift
      ;;
    -a|--arch)
      archType="$2"
      shift
      shift
      ;;
     -r|--release)
      isRelease=true
      echo "Release mode enabled"
      shift
      ;;
      -g|--gdb)
      isGdb=true
      echo "GDB mode enabled"
      shift
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}"

dubConfigType=
assemblyMarchType=
assemblyMarchSymbol=
linkerMarchType=
emulator=

case $archType in
  r32)
    dubConfigType=riscv32
    assemblyMarchType=rv32i2p1_m2p0_a2p1_f2p2_c2p0
    mabi=ilp32f
    assemblyMarchSymbol=rv32
    linkerMarchType=elf32lriscv
    emulator=qemu-system-riscv32
    ;;
  r64)
    dubConfigType=riscv64
    assemblyMarchType=rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0
    mabi=lp64d
    assemblyMarchSymbol=rv64
    linkerMarchType=elf64lriscv
    emulator=qemu-system-riscv64
    ;;
  *)
    echo "Not supported arch type: $archType"
    exit 1
    ;;
esac

if [[ "$isRelease" == "true" ]]; then
    dubConfigType="${dubConfigType}-release"
fi

echo "Build $buildType, arch: $archType, dub: $dubConfigType, asm: $assemblyMarchType"

time dub --quiet build --compiler=ldc2 "--config=$dubConfigType" "--build=$buildType"
if [[ $? -ne 0 ]]; then
    echo "DUB error" >&2
    exit 1
fi

riscvElfAs=
riscvElfLd=
riscvElfSize=
riscvElfObjcopy=
riscvElfObjdump=

if [[ $archType == "r32" ]]; then
     echo "Set toolchain for r32"
     riscvElfAs=riscv32-unknown-elf-as
     riscvElfLd=riscv32-unknown-elf-ld
     riscvElfSize=riscv32-unknown-elf-size
     riscvElfObjcopy=riscv32-unknown-elf-objcopy
     riscvElfObjdump=riscv32-unknown-elf-objcopy
elif [[ $archType == "r64" ]]; then
     riscvElfAs=riscv64-unknown-elf-as
     riscvElfLd=riscv64-unknown-elf-ld
     riscvElfSize=riscv64-unknown-elf-size
     riscvElfObjcopy=riscv64-unknown-elf-objcopy
     riscvElfObjdump=riscv64-unknown-elf-objcopy
else 
    echo "Unsupported arch type: $archType" >&2
    exit 1
fi

"$riscvElfAs" -march=$assemblyMarchType -mabi=$mabi  --defsym "$assemblyMarchSymbol"=1 "$bootSourceDir"/* -o "${bootFile}.o" -fno-pic -mno-relax
if [[ $? -ne 0 ]]; then
    echo "Boot build error" >&2
    exit 1
fi

#https://github.com/riscv-collab/riscv-gnu-toolchain/issues/356
"$riscvElfLd" --architecture "$assemblyMarchType" -m "$linkerMarchType" --gc-sections -T $scriptDir/src/link/riscv/qemu.ld -o "$kernelElf" "$buildDir"/*.o* "$buildDir"/*.a* 
if [[ $? -ne 0 ]]; then
    echo "Linker error" >&2
    exit 1
fi

"$riscvElfSize" "$kernelElf"

"$riscvElfObjcopy" -O binary "$kernelElf" "$kernelBin"
if [[ $? -ne 0 ]]; then
    echo "Kernel object file translation error" >&2
    exit 1
fi

"$riscvElfObjdump" -D "$kernelElf"  > kernel.list

if [[ -z $emulator ]]; then
    echo "Not found emulator" >&2
    exit 1
fi

qemuArgs=""
if [[ "$isGdb" == "true" ]]; then
    qemuArgs="$qemuArgs -s -S"
fi
"$emulator" -smp 2 -m 128M -serial stdio -bios none -machine virt -kernel "$kernelBin" $qemuArgs