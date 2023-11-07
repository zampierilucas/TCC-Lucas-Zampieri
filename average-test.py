import argparse
import glob
import re

def Average(lst):
    return sum(lst) / len(lst)

parser = argparse.ArgumentParser(description="Calculate average every 256 lines from a log file")
parser.add_argument("file_path", type=str, help="Path to the log file", required=True)
parser.add_argument('-t', '--type', type=str, help='Type log to process', required=True)
args = parser.parse_args()

extracted_numbers = []

for arch in ["x86_64", "arm64", "riscv", "powerpc"]:
    for cpus in [32, 64, 96, 128, 160, 192, 224, 256]:
        file_name = glob.glob(f"{args.file_path}{args.type}/{arch}/kcbench-{cpus}-*.log")
        with open(file_name[0], "r") as file:
            results_found = 0
            for line in file:
                matches = re.findall(r'seconds / ([0-9]+\.[0-9]+) kernels/hour', line)
                if matches:
                    results_found += 1
                    extracted_numbers.append(float(matches[0]))
            print(f"Average: ARCH {arch}: CPU {cpus}: {Average(extracted_numbers):.2f}")
