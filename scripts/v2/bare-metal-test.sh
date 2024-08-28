#!/usr/bin/env bash

logpath=${1:-"log"}
tech=${2:-"host"}

# Function to clean kernel
clean_kernel() {
  rm -rf /tmp/tcc-test/linux-6.6.47/
  tar -xf /tmp/tcc-test/linux-6.6.47.tar.xz -C /tmp/tcc-test/
}

# Function to run kcbench
run_kcbench() {
  cpus=$1
  arch=$2

  echo "$arch: Starting test with $cpus cpus"

  clean_kernel
  
  if [ "$arch" == "host" ]; then
    ../../kcbench/kcbench --detailed-results --jobs $cpus --iterations 150 --crosscomp-scheme fedora --src /tmp/tcc-test/linux-6.6.47 2>&1 | tee $logpath/$tech/$arch/kcbench-$cpus-$date.log
  else
    ../../kcbench/kcbench --detailed-results --bypass --cross-compile $arch --crosscomp-scheme fedora --jobs $cpus --iterations 150 --src /tmp/tcc-test/linux-6.6.47 2>&1 | tee $logpath/$tech/$arch/kcbench-$cpus-$date.log
  fi  
}

notify () {
  curl -d "$1" https://notify.lzampier.com/cmd
}

# Set date variable
date=$(date +"%Y_%m_%d_%I_%M_%p")

# Download kernel source
if [ ! -f /tmp/tcc-test/linux-6.6.47.tar.xz ]; then
  wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.6.47.tar.xz -P /tmp/tcc-test/
fi

# Loop for different CPU configurations
for cpus in 32 64 96 128 160 192 224 256; do
  notify "Start build for $cpus"
  for arch in "x86_64" "arm64" "riscv" "powerpc64"; do
    # Create logs directories
    mkdir -p "$logpath/$tech/$arch"

    # Run kcbench tests
    run_kcbench $cpus $arch
  done
done

notify "Test Complete"
