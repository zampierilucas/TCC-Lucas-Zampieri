import argparse

# Initialize variables to keep track of the line count and the sum of values
line_count = 0
sum_values = 0

# Define the number of lines to calculate the average
lines_per_average = 256

# Create an argument parser to accept the file path as a parameter
parser = argparse.ArgumentParser(description="Calculate average every 256 lines from a log file")
parser.add_argument("file_path", type=str, help="Path to the log file")
args = parser.parse_args()
# Open the log file for reading

file_name = args.file_path
with open(file_name, "r") as file:
    for line in file:
        # Parse the value from each line (assuming it's an integer value)
        try:
            value = int(float(line))
        except ValueError:
            continue  # Skip lines that are not valid integer values

        # Accumulate the values and increment the line count
        sum_values += value
        line_count += 1

        # Check if it's time to print the average
        if line_count % lines_per_average == 0:
            average = sum_values // lines_per_average
            print(f"{average}")

            # Reset the counters for the next average calculation
            line_count = 0
            sum_values = 0


