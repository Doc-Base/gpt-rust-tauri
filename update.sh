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
declare -a documentation_subdirectories=("book" "edition-guide" "nomicon" "perf-book" "reference" "rust-by-example" "tauri-docs")
for subdir in "${documentation_subdirectories[@]}"; do
  if [[ "$subdir" == "tauri-docs" ]]; then
    search_path="./$subdir/docs"
  else
    search_path="./$subdir/src"
  fi

  find "${search_path}" -type f -name "*.md" | while read -r src_file; do
    if [[ "$subdir" == "tauri-docs" ]]; then
      dest_file="${src_file/.\//./.output/tauri-docs/}" # Special path for tauri-docs
    else
      dest_file="${src_file/.\//./.output/}" # Replace './' with './.output/' at the beginning
      dest_file="${dest_file/src\//}" # Remove '/src/' part
    fi

    mkdir -p "$(dirname "$dest_file")"
    cp "$src_file" "$dest_file"
  done
done
echo "[GENERATION] Generating Custom GPT documentation... Done."

echo "================================================================================"
echo "[INDEXING] Updating Custom GPT documentation REAME..."
cat ./.output/README.md | sed '/## File List/q' >> ./.output/README.md.temp
mv ./.output/README.md.temp ./.output/README.md
sleep 1 # Wait for the filesystem to catch up
{
    echo ""
    find ./.output -type f -name "*.md" | grep -v 'README.md' | while read -r src_file; do
        # Get the relative file path
        relative_path="${src_file/.\//}"
        # Format as markdown link
        echo "- [${relative_path}](${relative_path})"
    done
    echo ""
} >> ./.output/README.md
echo "[INDEXING] Updating Custom GPT documentation README... Done."

echo "================================================================================"
echo "[ARCHIVING] Generating Custom GPT Knowledge Base..."
rm -Rf ./*.tar.gz
version_tag=$(date "+%Y.%m.%d")
archive_name="custom_gpt_rust_tauri_knowledge_base-v${version_tag}.tar.gz"
pushd ./.output
tar -czf "${archive_name}" *
popd
mv "./.output/${archive_name}" "./${archive_name}"
echo "[ARCHIVING] Generating Custom GPT Knowledge Base... Done."

echo "================================================================================"
echo ""
echo "You can now upload this archive to your Custom GPT Assistant: ./${archive_name}."
