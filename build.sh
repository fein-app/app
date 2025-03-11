#!/bin/bash
flutter build linux && 
cp -r -v /home/btibor/Documents/repos/fein_app/build/linux/x64/release/bundle/* /home/btibor/Documents/repos/fein_app/fein/usr/lib/fein/ &&
dpkg-deb --build fein