#!/bin/bash

# Define the directory where the repositories are cloned
DATA_DIR="public-repos"

# Create a temporary file to store unique environment variable names and their counts
UNIQUE_VARS_FILE=$(mktemp)

# Function to add a unique variable to the list or increment its count
add_unique_variable() {
    local var_name="$1"
    if grep -q "^$var_name=" "$UNIQUE_VARS_FILE"; then
        # If variable exists, increment its count
        sed -i '' "s/^$var_name=.*/$var_name=$(($(grep -E "^$var_name=" "$UNIQUE_VARS_FILE" | cut -d'=' -f2) + 1))/g" "$UNIQUE_VARS_FILE"
    else
        # If variable doesn't exist, add it with count 1
        echo "$var_name=1" >> "$UNIQUE_VARS_FILE"
    fi
}

# Loop through each repository folder and .env.[ANYTHING] files
find "$DATA_DIR" -type f -name ".env.*" | while read -r env_sample; do
    while IFS= read -r line; do
        # Extract the environment variable name
        if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=([^#]*) ]]; then
            env_var="${BASH_REMATCH[1]}"
            add_unique_variable "$env_var"
        fi
    done < "$env_sample"
done

# Sort the unique variables file based on counts
sort -t '=' -k2 -n -r "$UNIQUE_VARS_FILE" > sorted_unique_vars.tmp
mv sorted_unique_vars.tmp "$UNIQUE_VARS_FILE"

# Create the master .env.sample file with sorted unique environment variable names and their counts
MASTER_ENV_SAMPLE="master.env.sample"
> "$MASTER_ENV_SAMPLE"  # Clear the file

while IFS= read -r unique_var_count; do
    echo "$unique_var_count" >> "$MASTER_ENV_SAMPLE"
done < "$UNIQUE_VARS_FILE"

# Remove the temporary file with unique variables and counts
rm "$UNIQUE_VARS_FILE"

echo "Master .env.sample created with unique environment variable names and their counts sorted by count."
