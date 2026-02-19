#include <stdio.h>
#include <time.h>
#include "vqf.h"

#if defined(__ARM_ARCH_7EM__)
#include "core_cm4.h"
#endif

static void tick_start(uint32_t *start)
{
#if defined(__ARM_ARCH_7EM__)
    CoreDebug->DEMCR |= CoreDebug_DEMCR_TRCENA_Msk;
    DWT->CYCCNT = 0;
    DWT->CTRL |= DWT_CTRL_CYCCNTENA_Msk;
    *start = DWT->CYCCNT;
#else
    *start = (uint32_t)clock();
#endif
}

static uint32_t tick_end(uint32_t start)
{
#if defined(__ARM_ARCH_7EM__)
    return DWT->CYCCNT - start;
#else
    return (uint32_t)(clock() - (clock_t)start);
#endif
}

int main(void)
{
    vqf_params_t params;
    vqf_state_t state;
    vqf_coeffs_t coeffs;

    init_params(&params);
    initVqf(&params, &state, &coeffs, 0.001f, 0.001f, 0.01f);

    const int N = 50000;
    uint32_t t0;

    vqf_real_t gyr[3] = {0.01f, 0.02f, 0.03f};
    vqf_real_t acc[3] = {0.0f, 0.0f, 9.81f};

    tick_start(&t0);
    for (int i = 0; i < N; ++i) {
        updateGyr(&params, &state, &coeffs, gyr);
        updateAcc(&params, &state, &coeffs, acc);
    }
    uint32_t cycles = tick_end(t0);

    printf("Iterations: %d\n", N);
#if defined(__ARM_ARCH_7EM__)
    printf("Cycles total: %u, cycles/iter: %.2f\n", cycles, (double)cycles / (double)N);
#else
    printf("Clock ticks total: %u, ticks/iter: %.2f\n", cycles, (double)cycles / (double)N);
#endif

    vqf_real_t q6[4];
    getQuat6D(&state, q6);
    printf("sample quaternion: [%f, %f, %f, %f]\n", q6[0], q6[1], q6[2], q6[3]);

    return 0;
}
