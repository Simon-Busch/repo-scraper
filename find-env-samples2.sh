#!/bin/bash

# Define the directory where the repositories are cloned
DATA_DIR="public-repos"

# Create a temporary file to store unique environment variable names
UNIQUE_VARS_FILE=$(mktemp)

# Function to add a unique variable to the list
add_unique_variable() {
    local var_name="$1"
    if ! grep -q "^$var_name$" "$UNIQUE_VARS_FILE"; then
        echo "$var_name" >> "$UNIQUE_VARS_FILE"
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

# Create the master .env.sample file with unique environment variable names
MASTER_ENV_SAMPLE="master.env.sample"
> "$MASTER_ENV_SAMPLE"  # Clear the file

while IFS= read -r unique_var; do
    echo "$unique_var=" >> "$MASTER_ENV_SAMPLE"
done < "$UNIQUE_VARS_FILE"

# Remove the temporary file with unique variables
rm "$UNIQUE_VARS_FILE"

echo "Master .env.sample created with unique environment variable names."
