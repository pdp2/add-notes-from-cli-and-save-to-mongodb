#!/bin/bash

create_mock_commands() {
    local mock_bin_dir="$1"
    
    # Create mock directory if it doesn't exist
    mkdir -p "$mock_bin_dir"
    
    # Mock date command
    cat > "$mock_bin_dir/date" << 'EOF'
#!/bin/bash
echo "2024-01-01 12:00:00"
EOF
    chmod +x "$mock_bin_dir/date"
    
    # Mock mongoimport command
    cat > "$mock_bin_dir/mongoimport" << 'EOF'
#!/bin/bash
echo "Successfully imported document"
exit 0
EOF
    chmod +x "$mock_bin_dir/mongoimport"
}

# Function to add mock directory to PATH
add_mocks_to_path() {
    local mock_bin_dir="$1"
    export PATH="$mock_bin_dir:$PATH"
}

# Function to create a test config file
create_test_config() {
    local config_file="$1"
    local uri="${2:-mongodb://localhost:27017}"  # Default URI if not provided
    
    cat > "$config_file" << EOF
uri: $uri
EOF
}

# Function to create a test input file that handles both single and multiple tags
create_test_input() {
    # Check if at least the input file path is provided
    if [ $# -lt 1 ]; then
        echo "Error: Input file path is required" >&2
        return 1
    fi
    
    local input_file="$1"
    local username="${2:-$'\n'}"
    local password="${3:-$'\n'}"
    local note="${4:-Test note}"
    local tags=()
    
    # If we have more than 4 arguments, those are tags
    if [ $# -gt 4 ]; then
        shift 4  # Now $@ contains only the tags
        tags=("$@")
    fi
    
    # Create the initial content with extra newlines
    printf '%b\n' "$username" > "$input_file"
    printf '%b\n' "$password" >> "$input_file"
    printf '%b\n' "$note" >> "$input_file"
    
    # If no tags provided, add a default tag
    if [ ${#tags[@]} -eq 0 ]; then
        printf '%s\n' "tag1" >> "$input_file"
        # n to indicate no more tags
        printf '%s\n' "n" >> "$input_file"
    else
        # Add each provided tag
        local last_idx=$((${#tags[@]} - 1))
        local i=0
        for tag in "${tags[@]}"; do
            printf '%s\n' "$tag" >> "$input_file"
            if [ $i -eq $last_idx ]; then
                printf '%s\n' "n" >> "$input_file"
            else
                printf '%s\n' "y" >> "$input_file"
            fi
            ((i++))
        done
    fi
    
    printf '%s\n' "exit" >> "$input_file"
}