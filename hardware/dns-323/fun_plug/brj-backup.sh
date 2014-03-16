#!/bin/sh

/ffp/bin/rsync -vrlptDv --delete /mnt/HD_a2/baza/brj /mnt/HD_b2/backup/brj
/ffp/bin/rsync -vrlptDv --delete /mnt/HD_a2/baza/2009 /mnt/HD_b2/backup/2009

