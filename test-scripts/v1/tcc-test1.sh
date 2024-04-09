#!/usr/bin/env bash

date=$(date +"%Y_%m_%d_%I_%M_%p")

wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.4.15.tar.xz -P /dev/shm/

function clean_kernel {
  rm -rf /dev/shm/linux-6.4.15/
  tar -xf /dev/shm/linux-6.4.15.tar.xz -C /dev/shm/
}

mkdir log/

echo "Starting compile tests of kcbench for X86-64"
clean_kernel
./kcbench --detailed-results --crosscomp-scheme fedora --src /dev/shm/linux-6.4.15 2>&1 | tee log/log-kcbench-x86-$date.log

echo "Starting compile tests of kcbench for arm64"
clean_kernel
./kcbench --detailed-results --cross-compile arm64 --crosscomp-scheme fedora --src /dev/shm/linux-6.4.15 2>&1 | tee log/log-kcbench-arm64-$date.log

echo "Starting compile tests of kcbench for risv"
clean_kernel
./kcbench --detailed-results --cross-compile riscv --crosscomp-scheme fedora --src /dev/shm/linux-6.4.15 2>&1 | tee log/log-kcbench-risv-$date.log

echo "Starting compile tests of kcbench for powerpc"
clean_kernel
./kcbench --detailed-results --cross-compile powerpc --crosscomp-scheme fedora --src /dev/shm/linux-6.4.15 2>&1 | tee log/log-kcbench-powerpc-$date.log
