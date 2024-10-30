#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/mocks"

# Setup runs before each test
setup() {
    # Store the test script directory path
    TMP_DIR="$(mktemp -d)"
    TEST_DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    SAVE_SCRIPT_DIR="$(cd $TEST_DIR && cd .. && pwd)"
    SAVE_SCRIPT="$SAVE_SCRIPT_DIR/save"
    
    # Create test config file in the script directory
    TEST_CONFIG_FILE="${SAVE_SCRIPT_DIR}/config.yaml"
    # Backup existing config if it exists
    if [ -f "$TEST_CONFIG_FILE" ]; then
        mv "$TEST_CONFIG_FILE" "${TEST_CONFIG_FILE}.bak"
    fi
    
    # Add script directory to PATH
    # PATH="$SCRIPT_DIR:$PATH"
    
    # Create and setup mock commands
    MOCK_BIN_DIR="$TMP_DIR/mock_bin"
    create_mock_commands "$MOCK_BIN_DIR"
    add_mocks_to_path "$MOCK_BIN_DIR"

    # Debug output
    echo "Temp directory: $TMP_DIR"
    echo "Test directory: $TEST_DIR"
    echo "Save script path: $SAVE_SCRIPT"
    echo "Config file path: $TEST_CONFIG_FILE"
}

# Teardown runs after each test
teardown() {
    # Restore original config if it existed
    if [ -f "${TEST_CONFIG_FILE}.bak" ]; then
        mv "${TEST_CONFIG_FILE}.bak" "$TEST_CONFIG_FILE"
    else
        rm -f "$TEST_CONFIG_FILE"
    fi
    rm -rf "$TMP_DIR"

    # Clean up note_temp.json
    rm -f "$NOTE_TEMP_FILE"
}

@test "successful note creation with config file" {
    # Verify script exists and is executable
    [ -f "$SAVE_SCRIPT" ]
    [ -x "$SAVE_SCRIPT" ]
    
    # Create test config file
    create_test_config "$TEST_CONFIG_FILE"
    
    # Create a temporary input file
    INPUT_FILE="$TMP_DIR/input.txt"
    USER_NAME="fred"
    PASSWORD="welcome"
    NOTE="What a lovely day"
    #TAGS=("tag1" "tag2")
    TAGS="random"
    create_test_input "$INPUT_FILE" $USER_NAME $PASSWORD "$NOTE" $TAGS
    
    # Run the script with input file using full path
    run bash -c "cat ${INPUT_FILE} | ${SAVE_SCRIPT}"
    
    # Debug output
    echo "Status: $status"
    echo "Output: $output"
    
    # The note_temp.json should be in the script directory
    NOTE_TEMP_FILE="${SAVE_SCRIPT_DIR}/note_temp.json"
    [ -f "$NOTE_TEMP_FILE" ]
    
    # Verify JSON content
    run jq -r '.username' "$NOTE_TEMP_FILE"
    echo "JSON username output: $output"
    [ "$output" = $USER_NAME ]
    
    run jq -r '.note' "$NOTE_TEMP_FILE"
    echo "JSON note output: $output"
    [ "$output" = "$NOTE" ]
    
    run jq -r '.tags[0]' "$NOTE_TEMP_FILE"
    echo "JSON tags output: $output"
    [ "$output" = $TAGS ]
}