#!/bin/sh

#
# brj@transmission, automate. http://brj.pp.ru/
#

TRDIR=/mnt/HD_b2/torrent/watch
TRLOG=/mnt/HD_a2/ffp/brj/tr/brj-tr.log
TRSAVE=/mnt/HD_b2/torrent/saved
TRCOMP=/mnt/HD_b2/torrent/comp

# Begin magic

for file in `ls -1 ${TRDIR}/*.torrent` 
 do
  if [ "$file" != "${TRDIR}/*.torrent" ];
   then
    echo [`date`] "$file" added to queue. >> ${TRLOG}
    /ffp/bin/transmission-remote -a "$file"
    echo "$?"
    echo [`date`] "$file" moved to save queue. >> ${TRLOG}
    mv "$file" ${TRSAVE}
   fi
done

# The End ;-)
 
exit 0
