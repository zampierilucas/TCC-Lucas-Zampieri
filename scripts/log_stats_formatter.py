#!/usr/bin/env python3

import argparse
import glob
import re
import statistics


def parse_arguments():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(description="Calculate average every 256 lines from a log file")
    parser.add_argument("file_path", type=str, help="Path to the log file")
    parser.add_argument('-t', '--type', type=str, help='Type log to process', required=False, default='')

    group_data = parser.add_mutually_exclusive_group(required=True)
    group_data.add_argument('-a', '--average', action='store_true', help='Print the average of the tests')
    group_data.add_argument('-s', '--standard-deviation', action='store_true', help='Print the standard deviation')

    format_output = parser.add_mutually_exclusive_group(required=True)
    format_output.add_argument('-e', '--excel', action='store_true', help='Print formatted to Excel table')
    format_output.add_argument('-p', '--gnuplot', action='store_true', help='Print formatted to gnuplot table')

    return parser.parse_args()


def calculate_average(lst):
    """Calculate and return the average of a list, rounded to 2 decimal places."""
    return round(sum(lst) / len(lst), 2)


def process_files(args):
    """Process log files based on architecture and CPU count."""
    architectures = ["x86_64", "arm64", "riscv", "powerpc64"]
    cpu_counts = [32, 64, 96, 128, 160, 192, 224, 256]

    for arch in architectures:
        print_architecture_header(arch, args)

        for cpus in cpu_counts:
            file_search_pattern = f"{args.file_path}{args.type}/{arch}/kcbench-{cpus}-*.log"
            file_name = glob.glob(file_search_pattern)

            if not file_name:
                print(f"File not found: {file_search_pattern}")
                continue

            extracted_numbers = extract_numbers_from_file(file_name[0])

            if args.average:
                output_average(extracted_numbers, cpus, args)
            elif args.standard_deviation:
                output_standard_deviation(extracted_numbers, cpus, args)

        if args.gnuplot:
            print("EOD")


def print_architecture_header(arch, args):
    """Print architecture header based on output format."""
    if args.excel:
        print(f"\n\nARCH {arch}")
    if args.gnuplot:
        print(f"\n\n${arch} << EOD")


def extract_numbers_from_file(file_path):
    """Extract numbers from a log file based on a regex pattern."""
    extracted_numbers = []
    with open(file_path, "r") as file:
        for line in file:
            matches = re.findall(r'seconds / ([0-9]+\.[0-9]+) kernels/hour', line)
            if matches:
                extracted_numbers.append(float(matches[0]))
    return extracted_numbers


def output_average(numbers, cpus, args):
    """Output the average of numbers in the specified format."""
    average = str(calculate_average(numbers))
    if args.excel:
        print(average.replace('.', ','), end="\t")
    if args.gnuplot:
        print(f"{cpus} {average}")


def output_standard_deviation(numbers, cpus, args):
    """Output the standard deviation of numbers in the specified format."""
    standard_deviation = str(round(statistics.stdev(numbers), 5))

    if args.excel:
        print(standard_deviation.replace('.', ','), end="\t")

    if args.gnuplot:
        print(f"{cpus} {standard_deviation}")


if __name__ == "__main__":
    args = parse_arguments()
    process_files(args)
