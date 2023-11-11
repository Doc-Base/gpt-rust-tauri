#!/bin/bash
set -e

echo "================================================================================"
echo "[SUBMODULES] Updating submodules..."
git submodule update --init
echo "[SUBMODULES] Updating submodules... Done."

# echo "================================================================================"
# echo "[CRATES.IO] Updating database dumps..."
# rm -f ./db-dump.tar.gz
# wget https://static.crates.io/db-dump.tar.gz
# tar -xf ./db-dump.tar.gz
# rm -f ./db-dump.tar.gz
# echo "[CRATES.IO] Updating database dumps... Done."

echo "================================================================================"
echo "[GENERATION] Generating Custom GPT documentation..."
find ./.output -mindepth 1 ! -name 'README.md' -exec rm -Rf {} +
sleep 1 # Wait for the filesystem to catch up
declare -a documentation_subdirectories=("book" "edition-guide" "nomicon" "perf-book" "reference" "rust-by-example")
for subdir in "${documentation_subdirectories[@]}"; do
  find "./$subdir" -type f -name "*.md" | while read -r src_file; do
      dest_file="${src_file/.\//./.output/}" # Replace './' with './.output/' at the beginning
      dest_file="${dest_file/src\//}" # Remove '/src/' part
      mkdir -p "$(dirname "$dest_file")"
      cp "$src_file" "$dest_file"
  done
done
echo "[GENERATION] Generating Custom GPT documentation... Done."

echo "================================================================================"
echo "[ARCHIVING] Generation Custom GPT Knowledge Base..."
rm -Rf ./*.tar.gz
current_datetime=$(date "+%Y%m%d-%H%M%S")
archive_name="CUSTOM-GPT-RUST-TAURI-KNOWLEDGE-BASE_${current_datetime}.tar.gz"
tar -czf "${archive_name}" ./.output
echo "[ARCHIVING] Generation Custom GPT Knowledge Base... Done."

echo "================================================================================"
echo ""
echo "You can now upload this archive to your Custom GPT Assistant: ${archive_name}."
