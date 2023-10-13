#!/bin/bash

echo "[%NAME%] start init.sh"
echo "[%NAME%] start activate conda base"
conda activate base
echo "[%NAME%] end activate conda base"

# To make container useful in both interactive sessions
# and batch processing, check if xterm is available.
# If so, start up xterm. If not, get ready for
# incoming processing command.
if xhost >& /dev/null; then 
	# Display exists
	xterm -T $1
else 
	# Display invalid"
	exec "$@"
fi
echo "[%NAME%] end init.sh"
