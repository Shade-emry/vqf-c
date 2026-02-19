# EPS (FLT_EPSILON) — a nte on how it works

## Quick intuition

Think of `EPS` as the graininess of floating‑point arithmetic — the smallest step that the computer can reliably tell apart from zero at the scale of 1. In code we use it as a safety net: if a quantity is smaller than this grain, treat it as numerically indistinguishable from zero.

## The precise definition

- `EPS` here is defined as `FLT_EPSILON` in `src/vqf.c` (`#define EPS FLT_EPSILON`).
- Formally: `FLT_EPSILON` is the smallest ε > 0 such that 1.0f + ε != 1.0f for IEEE‑754 single precision.

In other words, it is not an application tolerance — it answers the question “can the machine tell this value apart from zero?”

---

## Where we use it in VQF (and why)

1) Normalization guard

```c
vqf_real_t n = norm(vec, N);
if (n < EPS) { return; }
```

 if ||v|| is at or below machine noise, do not attempt 1/||v||. Dividing would amplify rounding error and produce nonsense.

2) Matrix inversion singularity test

```c
if (det >= -EPS && det <= EPS) { /* singular */ }
```

Interpreted: if |det(A)| is within the machine’s indistinguishable band around zero, treat A as singular — numerical inversion would be ill‑conditioned.

3) Gyroscope (quaternion) update short‑circuit

```c
if (gyrNorm > EPS) { /* apply small rotation */ }
```

Meaning: angular rates smaller than machine granularity do not produce a meaningful rotation; skipping them avoids wasted work and avoids feeding noise into the quaternion math.

---

## Does this influence the filter’s behaviour?

Short answer: no, not in normal operation. Using `FLT_EPSILON` only prevents pathological numerical cases — it does not impose domain‑level thresholds (like sensor noise or motion detection limits).

Longer answer: if you replace `EPS` with a much larger number, you begin collapsing small but physically real signals into “zero”. That will change filter outputs. So we use machine epsilon strictly for numerical safety, and use separate, domain‑appropriate tolerances for algorithmic decisions.

---

## Practical recommendation (theorems and practice)

- Keep `EPS == FLT_EPSILON` for machine‑level guards.
- If you need tolerant behaviour at the algorithm level, introduce explicit tolerances with descriptive names. Example:

```c
#define VQF_NORMALIZE_TOL 1e-6f  // meaningful vector magnitude threshold
#define VQF_DET_TOL       1e-9f  // treat determinants below this as singular
#define VQF_GYR_TOL       1e-6f  // ignore angular rates below sensor noise floor
```

Rationale: separating machine safety (ε) from model assumptions (tolerances) keeps intent clear and prevents accidental algorithmic changes when you tweak numerical guards.

---

## Tests to prove correctness

- Unit tests at the boundary of each tolerance (||v|| = 0.9·tol, = 1.1·tol).
- Verify matrix inversion returns `false` when |det| ≤ det_tol and succeeds when |det| ≫ det_tol.
- Confirm quaternion remains unchanged for |ω| < gyr_tol but updates for larger ω.

---

