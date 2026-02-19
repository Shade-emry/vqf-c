# VQF-C: A Lightweight Implementation of VQF for Embedded Devices

**VQF-C** is a C language implementation of the full [VQF](https://github.com/dlaidig/vqf), with credit to the original project's author for their pioneering work. This project aims to bring the full capabilities of VQF to embedded devices such as Cortex-M4F and RISC-V MCUs, with minimal overhead.

## Key Highlights
- **Full Version VQF Functionality**: The implementation retains the full feature set of the original [VQF full version](https://github.com/dlaidig/vqf/blob/main/vqf/cpp/vqf.cpp).
- **Easy Integration**: The code is structured to be easily integrated into existing C environments for embedded MCUs/chips.

## Usage
To use VQF-C in your embedded application, include the headers and utilize the provided functions.

```c
#include "vqf.h"

int main() {
    // Initialize VQF-C and perform operations
    vqf_real_t gyr[3];
    vqf_real_t acc[3];
    vqf_real_t mag[3];

    vqf_real_t quat6D[4];
    vqf_real_t quat9D[4];

    vqf_real_t gyrTs = 0.000250;
    vqf_real_t accTs = 0.001;
    vqf_real_t magTs = 5.0;
    initVqf(gyrTs, accTs, magTs);

    while (1) {
        // Update VQF-C with new sensor data
        if (newGyrData) updateGyr(gyr);
        if (newAccData) updateAcc(acc);
        if (newMagData) updateMag(mag);

        if (newGyrData || newAccData) {
            quat6D = getQuat6D();
        }

        if (newMagData) {
            quat9D = getQuat9D();
        }
    }

    return 0;
}
```
## CMSIS‑DSP integration (Cortex‑M4 / nRF52)

This repository now includes optional CMSIS‑DSP acceleration for Cortex‑M4 targets (useful for nRF52 series).

- Replaced hot‑path math/quaternion/vector operations with CMSIS‑DSP calls when compiled with `-DUSE_CMSIS_DSP`.
- Added a `Makefile` target to build for Cortex‑M4F and a small benchmark (`bench/bench_cmsis.c`).

Quick build (nRF52840 / Cortex‑M4F with FPU):

1. Install arm-none-eabi toolchain and have a CMSIS‑DSP library available (Nordic SDK includes it).
2. Run:

   make cortex-m4 CMSIS_PATH=/path/to/CMSIS

Notes:
- The code chooses the CMSIS‑DSP accelerated paths only when `USE_CMSIS_DSP` is defined (Makefile passes that flag for the ARM build).
- If your target doesn't have an FPU (e.g. nRF52832), compile without `-mfpu`/`-mfloat-abi=hard` and prefer the fixed‑point CMSIS APIs (future work).

Benchmarking:
- Host:  make bench
- ARM:   make bench-arm CMSIS_PATH=/path/to/CMSIS



## License
VQF-C is open source and available under the [MIT License](https://opensource.org/license/mit). This means that you can use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software. The full terms of the license are detailed in the [LICENSE](/LICENSE) file.

For a quick overview, here are some key points about the [MIT License](https://opensource.org/license/mit):

- **Free to use**: You can use VQF-C in your projects without any cost.
- **Permissive**: You can modify the source code and distribute your modified versions.
- **No Warranty**: The software is provided "as is" without any warranties.
- **Requiring preservation of copyright and license notices**: You must include the copyright notice and a pointer to where the MIT License can be found in any substantial portions of the software.

For the full legal text, see the [LICENSE](/LICENSE) file.
