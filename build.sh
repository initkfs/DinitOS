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

dub build --compiler=ldc2
if [[ $? -ne 0 ]]; then
    echo "DUB error" >&2
    exit 1
fi

riscv64-unknown-elf-as -mno-relax -march=rv64imac "$bootSourceDir"/* -c -o "${bootFile}.o"
if [[ $? -ne 0 ]]; then
    echo "Boot build error" >&2
    exit 1
fi

riscv64-unknown-elf-ld --gc-sections -T $scriptDir/linker.ld -o "$kernelElf" "$buildDir"/*.o* "$buildDir"/*.a* 
if [[ $? -ne 0 ]]; then
    echo "Linker error" >&2
    exit 1
fi

riscv64-unknown-elf-objcopy  -O binary "$kernelElf" "$kernelBin"
if [[ $? -ne 0 ]]; then
    echo "Kernel object file translation error" >&2
    exit 1
fi

#riscv64-unknown-elf-objdump -D "$kernelBin"  > kernel.list

qemu-system-riscv64 -serial stdio -bios none -machine virt -kernel "$kernelBin"