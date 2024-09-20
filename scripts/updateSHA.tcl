# This script is called by quartus before compilation
post_message -type info "Updating GIT SHA"

exec bash scripts/updateSHA.sh

