#!/usr/bin/env bash

set -e

echo "prepping clamav"

rm -rf bin
rm -rf lib
rm lambda_layer.zip || true

mkdir -p lib
# include any manually included libraries
cp -r /opt/tmp-lib/* lib

yum update -y
amazon-linux-extras install epel -y
yum install -y cpio yum-utils zip

# extract binaries for clamav, json-c, pcre
mkdir -p /tmp/build
pushd /tmp/build
echo "-- Downloading packages --"
yumdownloader -x \*i636 --archlist=x86_64 --resolve --installroot=/tmp/build --releasever=/ clamav clamav-lib clamav-update clamd
# yum install --downloadonly --downloaddir=/tmp/build clamav clamd

echo "-- Extracting packages --"
for i in *.rpm; do
  rpm2cpio "$i" | cpio -vimd
done

# reset the timestamps so that we generate a reproducible zip file where
# running with the same file contents we get the exact same hash even if we
# run the same build on different days
find usr -exec touch -t 200001010000 "{}" \;
popd

mkdir -p bin

cp /tmp/build/usr/bin/clamscan /tmp/build/usr/bin/freshclam bin/.
cp -r /tmp/build/usr/lib64/* lib/.
cp freshclam.conf bin/freshclam.conf

zip -r9 /opt/app/lambda_layer.zip bin
zip -r9 /opt/app/lambda_layer.zip lib
