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
./kcbench/kcbench --detailed-results --jobs 288 --iterations 15 --crosscomp-scheme fedora --src /dev/shm/linux-6.4.15 2>&1 | tee log/log-kcbench-x86-288-$date.log

clean_kernel
./kcbench/kcbench --detailed-results --jobs 256 --iterations 15 --crosscomp-scheme fedora --src /dev/shm/linux-6.4.15 2>&1 | tee log/log-kcbench-x86-256-$date.log

clean_kernel
./kcbench/kcbench --detailed-results --jobs 128 --iterations 15 --crosscomp-scheme fedora --src /dev/shm/linux-6.4.15 2>&1 | tee log/log-kcbench-x86-128-$date.log

clean_kernel
./kcbench/kcbench --detailed-results --jobs 64 --iterations 15 --crosscomp-scheme fedora --src /dev/shm/linux-6.4.15 2>&1 | tee log/log-kcbench-x86-64-$date.log

