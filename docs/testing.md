Run the provided benchmark on your dev board (nRF52840) and compare cycles/iteration with and without USE_CMSIS_DSP.
Profile your real IMU update loop (DWT_CYCCNT) to confirm hotspots are improved.
Optimized and required use of nRF52840 (Cortex‑M4F **has FPU**) as it utilizes single‑precision FPU so use CMSIS‑DSP f32 for best performance