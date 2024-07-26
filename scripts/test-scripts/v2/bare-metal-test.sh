#!/usr/bin/env bash

logpath=${1:-"log"}
tech=${2:-"host"}

# Function to clean kernel
clean_kernel() {
  rm -rf /tmp/shm/linux-6.4.15/
  tar -xf /tmp/shm/linux-6.4.15.tar.xz -C /tmp/shm/
}

# Function to run kcbench
run_kcbench() {
  cpus=$1
  arch=$2

  echo "$arch: Starting test with $cpus cpus"

  clean_kernel
  ../../kcbench/kcbench --detailed-results --cross-compile $arch --jobs $cpus --iterations 100 --crosscomp-scheme fedora --src /tmp/shm/linux-6.4.15 2>&1 | tee $logpath/$tech/$arch/kcbench-$cpus-$date.log
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

notify () {
  msg=$1
  curl -d "$1" https://notify.lzampier.com/cmd
}

# Set date variable
date=$(date +"%Y_%m_%d_%I_%M_%p")

# Download kernel source
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.4.15.tar.xz -P /tmp/shm/

# Loop for different CPU configurations
for cpus in 32 64 96 128 160 192 224 256; do
  notify "Start build for $cpus"
  for arch in "x86_64" "arm64" "riscv" "powerpc"; do
    # Create logs directories
    mkdir -p "$logpath/$tech/$arch"

    # Run kcbench tests
    run_kcbench $cpus $arch
  done
done

notify "Test Complete"
