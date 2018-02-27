#!/bin/sh
cd "C:\Program Files (x86)\World of Warcraft"
git checkout master
git add .
git commit -am "Nightly Update"
git push -f WoWUI master