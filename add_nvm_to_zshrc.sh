#!/bin/bash

# Text to append to .zshrc
cat << 'EOF' >> ~/.zshrc

# NVM initialization
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOF

echo "NVM initialization added to ~/.zshrc"
echo "To apply changes, run 'source ~/.zshrc' or restart your terminal" 