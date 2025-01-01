#!/bin/bash

function copyIt() {
  # Define the list of exclusions.
  EXCLUDES=(.git README.md setup.sh LICENSE)

  # Build the grep pattern to exclude all items in the list.
  PATTERN=$(printf "|%s" "${EXCLUDES[@]}")
  PATTERN="${PATTERN:1}" # Remove the leading "|"

  # Use cp and grep with the exclusion pattern.
  cp -r $(ls | grep -v -E "(${PATTERN})") $HOME

  # Install zsh if it is not already installed
  if ! command -v zsh &> /dev/null; then
    echo "Zsh is not installed. Installing zsh..."
    bash "$HOME/scripts/install-zsh.sh"
  fi
  # Autostart zsh if bash is the default shell
  cat <<EOT >> $HOME/.bashrc

if command -v zsh &> /dev/null; then
  exec zsh
else
  exec "$HOME/.local/bin/zsh"
fi
EOT

  # # Define the files and directories to exclude
  # EXCLUDES=(
  # 	".git"
  # 	"setup.sh"
  # 	"README.md"
  # 	"LICENSE"
  # )
  # # Create the tar exclude options
  # EXCLUDE_ARGS=""
  # for item in "${EXCLUDES[@]}"; do
  # 	EXCLUDE_ARGS+="--exclude=$item "
  # done
  # # Use tar to archive the directory excluding specific files, then extract to $HOME
  # tar -cf - $EXCLUDE_ARGS . | tar -xf - -C "$HOME"

  echo "Setup complete."
}

if [[ -z "$1" && ("$1" == "--force" || "$1" == "-f") ]]; then
  copyIt
else
  while true; do
    read -p "This will overwrite files in your home directory. Are you sure? (y/n) " -n 1
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      copyIt
      break
    elif [[ $REPLY =~ ^[Nn]$ ]]; then
      break
    fi
  done
fi
