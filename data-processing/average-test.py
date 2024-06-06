import argparse
import glob
import re
import statistics

parser = argparse.ArgumentParser(description="Calculate average every 256 lines from a log file")
parser.add_argument("file_path", type=str, help="Path to the log file")
parser.add_argument('-t', '--type', type=str, help='Type log to process', required=False,default='')

group_data = parser.add_mutually_exclusive_group(required=True)
group_data.add_argument('-a','--average', action='store_true', help='Print the average the tests')
group_data.add_argument('-s','--standard-deviation', action='store_true', help='Print the standard deviation')

args = parser.parse_args()


def Average(lst):
    return round(sum(lst) / len(lst), 2)


# Iterate over all the architectures used
for arch in ["x86_64", "arm64", "riscv", "powerpc"]:
    print(f"\n\nARCH {arch}")
    # Iterate over all the core count test results
    for cpus in [32, 64, 96, 128, 160, 192, 224, 256]:
        extracted_numbers = []

        # File to process
        file_search_pattern = f"{args.file_path}{args.type}/{arch}/kcbench-{cpus}-*.log"
        file_name = glob.glob(file_search_pattern)

        # Check if file was found
        if not file_name:
            print(f"File not found: {file_search_pattern}")
            continue

        # Iterate over a single test result file
        with open(file_name[0], "r") as file:
            for line in file:
                # Search for kernel/hour result
                if matches := re.findall(r'seconds / ([0-9]+\.[0-9]+) kernels/hour', line):
                    extracted_numbers.append(float(matches[0]))

        if args.average:
            # Calculate list averate and print in excel format
            average = str(Average(extracted_numbers)).replace('.',',')
            print(average, end="\t")
        elif args.standard_deviation:
            # Calculate standart deviation and print in excel format
            standart_deviation = str(round(statistics.stdev(extracted_numbers),5)).replace('.',',')
            print(standart_deviation, end="\t")