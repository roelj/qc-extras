# QC research and development

This repository contains notes and source code for extending the NDSP Quad
Cortex, and provides a user-space program to enhance its functionality.

## Development setup

### Cross-compiler toolchain

In order to cross-compile from your development machine to the Quad Cortex,
we need to install a cross-compiler toolchain.

To discover which hardware we need to target, we can check `/proc/cpuinfo` on
the Quad Cortex:
```
# cat /proc/cpuinfo | grep -E "Hardware|Features|model name"
model name      : ARMv7 Processor rev 1 (v7l)
Features        : half thumb fastmult vfp edsp thumbee neon vfpv3 tls vfpv4 vfpd32
Hardware        : SC58x-EZKIT (Device Tree Support)
```

Knowing that we should target the `SC58x-EZKIT`, we can download and install the
[vendor's toolchain](https://www.analog.com/en/design-center/evaluation-hardware-and-software/software/linuxaddin.html#software-overview).

Note: We only need the `Linux Add-In for ADSP-SC5xx`.

### Third-party libraries to compile

Before being able to compile this repository's source code, we need to compile
third-party libraries.  There's a script in the `third-party` directory to set
things up quickly:
```
cd third-party
sh build-third-party-libs.sh
```

### Compiling this repository's code

After installing the cross-compiler toolchain, we need to configure this
repository's build system to use it.  Run the following from this Git
repository's root:

```
autoreconf -vif
CROSS_GCC=$(find /opt/analog/cces-linux-add-in -name "arm-linux-gnueabi-gcc")
./configure CC=${CROSS_GCC} --host=armv7 --prefix=$(pwd)/build-output
```

After successful completion, we will have a `build-output/bin/qc-controller`
after running:
```
make
make install
```

The `qc-controller` binary is meant to run on the Quad Cortex, so copy it to
the device and run it from there.
