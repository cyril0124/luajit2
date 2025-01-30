#!/bin/bash

luajit_dir=$(pwd)
install_dir=$(pwd)/install

cd $luajit_dir; make clean; make -j $(nproc); make install PREFIX=$install_dir

