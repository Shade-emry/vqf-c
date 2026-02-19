# Per-sample timestamps (microseconds) — API & usage

Summary
- New timestamp-aware update functions added to the C API: `updateGyrTs`, `updateAccTs`, `updateMagTs`.
- Each accepts a monotonic timestamp in microseconds (`uint64_t timestamp_us`). The library computes the sample interval (dt) from consecutive timestamps and uses it for integration and time‑based bookkeeping.

Why use timestamps?
- Handles jitter, dropped frames and irregular sampling correctly.
- Enables synchronization with other sensors (e.g. GPS) and replayed/recorded data containing timestamps.

API (signatures)
- void updateGyrTs(vqf_params_t *const params, vqf_state_t *const state, vqf_coeffs_t *const coeffs, const vqf_real_t gyr[3], uint64_t timestamp_us);
- void updateAccTs(vqf_params_t *const params, vqf_state_t *const state, vqf_coeffs_t *const coeffs, const vqf_real_t acc[3], uint64_t timestamp_us);
- void updateMagTs(vqf_params_t *const params, vqf_state_t *const state, vqf_coeffs_t *const coeffs, const vqf_real_t mag[3], uint64_t timestamp_us);

Behavior / notes
- Timestamp unit: microseconds (uint64_t). Provide a monotonic clock (e.g. steady hardware timer).
- The implementation stores per-sensor "last timestamp" fields in `vqf_state_t` (`lastGyrTsUs`, `lastAccTsUs`, `lastMagTsUs`).
- If the previous timestamp is unknown or the provided timestamp is invalid/non‑monotonic, the library falls back to the nominal sampling time configured in `coeffs->*Ts`.
- Sanity check: timestamps that imply an interval > 10 s are treated as invalid and the fallback sampling time is used.
- Filter coefficients (internal low-pass filters) are computed at `setup()` from the nominal `coeffs->*Ts`. The `*Ts` APIs use the provided dt for integration and time counters but do not re-compute filter coefficients — this covers most real-world jitter while keeping the API efficient.

Backward compatibility
- Existing functions `updateGyr`, `updateAcc`, `updateMag` remain unchanged and still use `coeffs->gyrTs/accTs/magTs`.
- The timestamped functions are additive and optional.

Quick example

```c
// initialize (nominal sample times in seconds)
initVqf(&params, &state, &coeffs, 0.01f, 0.01f, 0.02f);

// on each IMU sample with timestamps in microseconds
uint64_t ts_us = get_monotonic_time_us();
updateGyrTs(&params, &state, &coeffs, gyr, ts_us);
updateAccTs(&params, &state, &coeffs, acc, ts_us);
updateMagTs(&params, &state, &coeffs, mag, ts_us);

// read outputs
vqf_real_t q[4];
getQuat9D(&state, q);
```

Testing suggestions
- Unit tests with variable dt (jitter ±20%) — verify that integration and rest detection behave better than fixed-Ts variant.
- Replay datasets with dropped samples and compare orientation drift (timestamped vs fixed-Ts).
- Test monotonicity handling (older timestamps, repeated timestamps).

Implementation details (short)
- Added `lastGyrTsUs`, `lastAccTsUs`, `lastMagTsUs` to `vqf_state_t` and initialized in `resetState()`.
- New `*Ts` public APIs compute dt from timestamps and call internal helpers; legacy public APIs call the same internal helpers using `coeffs->*Ts`.
- Timestamp validation: non-monotonic or implausible dt falls back to nominal `coeffs->*Ts`.


