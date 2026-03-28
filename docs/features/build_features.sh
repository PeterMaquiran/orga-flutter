#!/bin/bash

# Configuration
INPUT_FILE="features.txt"

# Create a function to slugify text (lowercase, replace spaces/special chars with hyphens)
slugify() {
    echo "$1" | iconv -t ascii//TRANSLIT | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:] ' | tr ' ' '-' | sed 's/--/-/g'
}

current_cat=""

while IFS= read -r line || [ -n "$line" ]; do
    # 1. Detect Category (Lines like # AUTHENTICATION)
    if [[ $line =~ ^#[[:space:]]+([A-Z[:space:]/]+)$ ]]; then
        current_cat=$(slugify "${BASH_REMATCH[1]}")
        mkdir -p "$current_cat"
        echo "📂 Created folder: $current_cat"

    # 2. Detect ID (Lines like - id: AUTH-001)
    elif [[ $line =~ ^-[[:space:]]id:[[:space:]]([A-Z0-9-]+) ]]; then
        feat_id=$(echo "${BASH_REMATCH[1]}" | tr '[:upper:]' '[:lower:]')
        
        # Read the next line to get the 'name:' field
        IFS= read -r name_line
        if [[ $name_line =~ name:[[:space:]](.*) ]]; then
            feat_name=$(slugify "${BASH_REMATCH[1]}")
            
            # Combine into your requested format
            filename="${feat_id}-${feat_name}.yml"
            
            # Create the empty file (or folder if you prefer)
            touch "$current_cat/$filename"
            echo "  📄 Created: $current_cat/$filename.yml"
        fi
    fi
done < "$INPUT_FILE"

echo "---"
echo "Done! Structure created successfully."