#!/bin/bash

cd layout
tar zcvf layout.tar.gz *
mv layout.tar.gz ../
cd ..
docker build -t apnex/cluster -f ./esx-cluster.docker .
rm layout.tar.gz
