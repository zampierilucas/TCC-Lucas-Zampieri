#!/usr/bin/env bash

# Function to run kcbench
run_kcbench() {
  cpus=$1
  echo "Starting test with $cpus cpus"

  clean_kernel
  ./kcbench/kcbench --detailed-results --jobs $cpus --iterations 1 --crosscomp-scheme fedora --src /dev/shm/linux-6.4.15 2>&1 | tee log/log-kcbench-x86-$cpus-$date.log
}

# Function to clean kernel
clean_kernel() {
  rm -rf /dev/shm/linux-6.4.15/
  tar -xf /dev/shm/linux-6.4.15.tar.xz -C /dev/shm/
}

# Function to log core clocks
log_core_clocks() {
  while true; do
    cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq >> log/core_clocks/core2_clocks-$date.log
    sleep 1
  done
}

# Set date variable
date=$(date +"%Y_%m_%d_%I_%M_%p")

# Download kernel source
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.4.15.tar.xz -P /dev/shm/

# Create log directory
mkdir -p log/
mkdir -p log/core_clocks

# Start logging core clocks in the background
#log_core_clocks &
#echo $! > "log/core_clocks_pid.txt"

# Loop for different CPU configurations
for cpus in {4..4..4}; do
  # Run kcbench
  run_kcbench $cpus
done

# Read the process ID from the file and stop logging core clocks
#core_clocks_pid=$(cat "log/core_clocks_pid.txt")
#kill "$core_clocks_pid"
#rm log/core_clocks_pid.txt
