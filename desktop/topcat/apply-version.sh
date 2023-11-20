#!/bin/bash

topcatimage=images.canfar.net/skaha/topcat

# Extract topcat version from image.
VERSION=`docker run ${topcatimage}:latest topcat -version | grep -i TOPCAT.version | sed 's/.*ersion //'`

# Prepare tags: topcat version and build version (timestamp).
TAGS="$VERSION $(date -u +'%Y%m%dT%H%M%S')"
echo "tags: $TAGS"

# Tag image.
for t in $TAGS; do
   docker image tag ${topcatimage}:latest ${topcatimage}:$t
done
unset TAGS
unset VERSION
docker image list ${topcatimage}
