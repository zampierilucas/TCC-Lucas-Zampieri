#!/usr/bin/env bash

logpath=${1:-"log"}
tech=${2:-"host"}

# Function to clean kernel
clean_kernel() {
  rm -rf /dev/shm/linux-6.4.15/
  tar -xf /dev/shm/linux-6.4.15.tar.xz -C /dev/shm/
}

# Function to run kcbench
run_kcbench() {
  cpus=$1
  arch=$2

  echo "$arch: Starting test with $cpus cpus"

  clean_kernel
  ./kcbench/kcbench --detailed-results --cross-compile $arch --jobs $cpus --iterations 50 --crosscomp-scheme fedora --src /dev/shm/linux-6.4.15 2>&1 | tee $logpath/$tech/$arch/kcbench-$cpus-$date.log
}

# Function to log core clocks
log_core_clocks() {
  cpus=$1
  arch=$2

  echo "$arch: Starting Clock measurement with $cpus cpus"
  if [ $tech = 'vm' ]; then
    ssh epyc-host "while true; do cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq; sleep 1; done" >> $logpath/$tech/$arch/core_clocks-$cpus-$date.log &
  else
    bash -c "while true; do cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq; sleep 1; done" >> $logpath/$tech/$arch/core_clocks-$cpus-$date.log &
  fi
}

# Set date variable
date=$(date +"%Y_%m_%d_%I_%M_%p")

# Download kernel source
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.4.15.tar.xz -P /dev/shm/

# Loop for different CPU configurations
for cpus in 32 64 96 128 160 192 224 256; do
  for arch in "x86_64" "arm64" "riscv" "powerpc"; do
    # Create logs directories
    mkdir -p "$logpath/$tech/$arch"
    # Start clock measurement for cpu count
    log_core_clocks $cpus $arch

    # Run kcbench tests
    run_kcbench $cpus $arch

    # Kill running clock measurement for cpu count
    if [ $tech = 'vm' ]; then
      ssh epyc-host "pkill -f 'cat /sys/devices/system/cpu/'"
    else
      pkill -f 'cat /sys/devices/system/cpu/'
    fi
  done
done
