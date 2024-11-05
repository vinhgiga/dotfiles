#!/bin/bash

function copyIt() {
	# Define the files and directories to exclude
	EXCLUDES=(
		".git"
		"setup.sh"
		"README.md"
		"LICENSE"
	)
	# Create the tar exclude options
	EXCLUDE_ARGS=""
	for item in "${EXCLUDES[@]}"; do
		EXCLUDE_ARGS+="--exclude=$item "
	done
	# Use tar to archive the directory excluding specific files, then extract to $HOME
	tar -cf - $EXCLUDE_ARGS . | tar -xf - -C "$HOME"
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
