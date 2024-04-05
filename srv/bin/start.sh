#!/bin/sh
#-------------------------------------------------------------------------#
if [ ! -f "/srv/data/001-prepare.sh.done" ]; then
  echo "/srv/bin/001-prepare.sh"
  /srv/bin/001-prepare.sh
  cp /srv/bin/001-prepare.sh /srv/data/001-prepare.sh.done
  exit
fi
#-------------------------------------------------------------------------#
if [ ! -f "/srv/data/002-setup.sh.done" ]; then
  echo "/srv/bin/002-setup.sh"
  /srv/bin/002-setup.sh
  cp /srv/bin/002-setup.sh /srv/data/002-setup.sh.done
  exit
fi
#-------------------------------------------------------------------------#
echo "/srv/bin/003-run.sh"
/srv/bin/003-run.sh
#-------------------------------------------------------------------------#