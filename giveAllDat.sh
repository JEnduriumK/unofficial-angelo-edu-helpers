#!/usr/bin/bash
#
#https://stackoverflow.com/questions/2297510/linux-shell-script-for-each-file-in-a-directory-grab-the-filename-and-execute-a

echo "All original .dat files" > alldat.txt
echo "" >> alldat.txt
for i in *.dat ; do
  [[ -f "$i" ]] || continue
  echo "$i" >> alldat.txt
  echo "------------------------------" >> alldat.txt
  cat "$i" >> alldat.txt
  echo "" >> alldat.txt
done
echo "All .dat files compiled in to alldat.txt"
