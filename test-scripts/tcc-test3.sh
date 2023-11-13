#!/usr/bin/env bash

# Function to get the current CPU clock speed
get_cpu_clock_speed() {
  cpupower frequency-info | grep 'current CPU frequency' | awk '{print $4}'
}

# Function to run kcbench
run_kcbench() {
  cpus=$1
  echo "Starting test with $cpus cpus"

  clean_kernel
  ./kcbench/kcbench --detailed-results --jobs $cpus --iterations 15 --crosscomp-scheme fedora --src /dev/shm/linux-6.4.15 2>&1 | tee log/log-kcbench-x86-$cpus-$date.log
}

# Function to clean kernel
clean_kernel() {
  rm -rf /dev/shm/linux-6.4.15/
  tar -xf /dev/shm/linux-6.4.15.tar.xz -C /dev/shm/
}

# Set date variable
date=$(date +"%Y_%m_%d_%I_%M_%p")

# Download kernel source
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.4.15.tar.xz -P /dev/shm/

# Create log directory
mkdir -p log/

# Loop for different CPU configurations
for cpus in {32..288..32}; do
  # Run kcbench in the background
  run_kcbench $cpus &

  # Get the process ID of the kcbench command
  kcbench_pid=$!

  # Log CPU clock speed to a file with the same pattern as kcbench
  while kill -0 $kcbench_pid 2>/dev/null; do
    current_clock_speed=$(get_cpu_clock_speed)
    echo "$date: Current CPU Clock Speed: $current_clock_speed" >> log/log-clock-x86-$cpus-$date.log
    # Time between measurements
    sleep 5 
  done
done

