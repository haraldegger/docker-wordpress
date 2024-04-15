#!/bin/sh
#-------------------------------------------------------------------------#
if [ ! -f "/srv/bin/001-prepare.done" ]; then
  echo "/srv/bin/001-prepare.sh"
  /srv/bin/001-prepare.sh
  echo "done" > /srv/bin/001-prepare.done 
  exit
fi
#-------------------------------------------------------------------------#
if [ ! -f "/srv/bin/002-setup.done" ]; then
  echo "/srv/bin/002-setup.sh"
  /srv/bin/002-setup.sh
  echo "done" > /srv/bin/002-setup.done 
  exit
fi
#-------------------------------------------------------------------------#
echo "/srv/bin/003-run.sh"
/srv/bin/003-run.sh
#-------------------------------------------------------------------------#