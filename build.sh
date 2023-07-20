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
bootSourceDir=$sourceDir/boot

bootFile=$buildDir/boot
kernelFile=$buildDir/kernel
kernelElf=${kernelFile}.elf
kernelBin=${kernelFile}.bin

POSITIONAL_ARGS=()
buildType=debug
archType=r32

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
    assemblyMarchType=rv32imac
    assemblyMarchSymbol=rv32
    linkerMarchType=elf32lriscv
    emulator=qemu-system-riscv32
    ;;
  r64)
    dubConfigType=riscv64
    assemblyMarchType=rv64imac
    assemblyMarchSymbol=rv64
    linkerMarchType=elf64lriscv
    emulator=qemu-system-riscv64
    ;;
  *)
    echo "Not supported arch type: $archType"
    exit 1
    ;;
esac

echo "Build $buildType, arch: $archType, dub: $dubConfigType, asm: $assemblyMarchType"

time dub --quiet build --compiler=ldc2 "--config=$dubConfigType" "--build=$buildType"
if [[ $? -ne 0 ]]; then
    echo "DUB error" >&2
    exit 1
fi

riscv64-unknown-elf-as -fno-pic -mno-relax -march=$assemblyMarchType --defsym "$assemblyMarchSymbol"=1 "$bootSourceDir"/* -c -o "${bootFile}.o"
if [[ $? -ne 0 ]]; then
    echo "Boot build error" >&2
    exit 1
fi

riscv64-unknown-elf-ld --architecture "$assemblyMarchType" -m "$linkerMarchType" --gc-sections -T $scriptDir/linker.ld -o "$kernelElf" "$buildDir"/*.o* "$buildDir"/*.a* 
if [[ $? -ne 0 ]]; then
    echo "Linker error" >&2
    exit 1
fi

riscv64-unknown-elf-objcopy  -O binary "$kernelElf" "$kernelBin"
if [[ $? -ne 0 ]]; then
    echo "Kernel object file translation error" >&2
    exit 1
fi

riscv64-unknown-elf-objdump -D "$kernelElf"  > kernel.list

if [[ -z $emulator ]]; then
    echo "Not found emulator" >&2
    exit 1
fi

"$emulator" -smp 2 -serial stdio -bios none -machine virt -kernel "$kernelBin" 
#-s -S