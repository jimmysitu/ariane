#!/bin/bash

# genesys2
if [ -z "${BOARD}" ]; then
    export BOARD="genesys2"
fi


# genesys2
if [ "$BOARD" = "genesys2" ]; then
  echo -n "Configuring for "
  echo "Genesys II"
  export XILINX_PART="xc7k325tffg900-2"
  export XILINX_BOARD="digilentinc.com:genesys2:part0:1.1"
  export CLK_PERIOD_NS="20"
fi

# miz701n
if [ "$BOARD" = "miz701n" ]; then
  echo -n "Configuring for "
  echo "Miz701N"
  export XILINX_PART="xc7z020clg400-2"
  export XILINX_BOARD=""
  export CLK_PERIOD_NS="20"
fi
