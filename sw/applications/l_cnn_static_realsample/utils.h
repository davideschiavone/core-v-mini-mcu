#ifndef UTILS_H
#define UTILS_H

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

// Define SIMULATION if you want to disable printing
// #define SIMULATION
#define TARGET

#ifdef SIMULATION
#pragma message ("SIMULATION environment")
#endif
#ifdef TARGET
#pragma message ("TARGET environment")
#endif

// Enable or disable printing
#ifndef SIMULATION
#define PRINTF(...) printf(__VA_ARGS__)
#else
#define PRINTF(...)
#endif

static float maxdiff = 0;
static int32_t maxdiffxp = 0;

// Assert functions, always print if failing
void assert_closef_si(float a, float b, float prec, int idx) {
    float diff = a - b;
    if (diff < 0) diff = -diff;
    if (diff > maxdiff) {
        maxdiff = diff;
        if (maxdiff > 0.0001)
            PRINTF("Max diff float: %f\n", maxdiff);
    }
    if (diff > prec) {
        printf("AF %d %f %f %d\n", __LINE__, a, b, idx);
        exit(EXIT_FAILURE);
    }
}

void assert_closei32_si(int32_t a, int32_t b, int32_t prec, int idx) {
    int32_t diff = a - b;
    if (diff < 0) diff = -diff;
    if (diff > maxdiffxp) {
        maxdiffxp = diff;
        if (maxdiffxp > 1)
            PRINTF("Max diff fxp: %d\n", maxdiffxp);
    }
    if (diff > prec) {
        printf("AI %d %d %d %d\n", __LINE__, a, b, idx);
        exit(EXIT_FAILURE);
    }
}

void assert_closef_s(float a, float b, float prec) {
    float diff = a - b;
    if (diff < 0) diff = -diff;
    if (diff > maxdiff) {
        maxdiff = diff;
        if (maxdiff > 0.0001)
            PRINTF("Max diff float: %f\n", maxdiff);
    }
    if (diff > prec) {
        printf("AF %d %f %f\n", __LINE__, a, b);
        exit(EXIT_FAILURE);
    }
}

void assert_closei32_s(int32_t a, int32_t b, int32_t prec) {
    int32_t diff = a - b;
    if (diff < 0) diff = -diff;
    if (diff > maxdiffxp) {
        maxdiffxp = diff;
        if (maxdiffxp > 1)
            PRINTF("Max diff fxp: %d\n", maxdiffxp);
    }
    if (diff > prec) {
        printf("AI %d %d %d\n", __LINE__, a, b);
        exit(EXIT_FAILURE);
    }
}

void assert_closef(float a, float b, float prec) {
    float diff = a - b;
    if (diff < 0) diff = -diff;
    if (diff > prec) {
        printf("AF %d %f %f\n", __LINE__, a, b);
        exit(EXIT_FAILURE);
    }
}

void assert_closei32(int32_t a, int32_t b, int32_t prec) {
    int32_t diff = a - b;
    if (diff < 0) diff = -diff;
    if (diff > prec) {
        printf("AI %d %d %d\n", __LINE__, a, b);
        exit(EXIT_FAILURE);
    }
}

// Vector export for plots
#if defined(SIMULATION) || defined(TARGET)
#define VECTOR_EXPORT(...)
#else
void vectorExport(float* a, int size, char filename[]) {
    FILE *filePointer;
    filePointer = fopen(filename, "w");
    if (filePointer == NULL) {
        printf("Failed to create file.\n");
        return;
    }
    for (int i=0; i<size; ++i) {
        fprintf(filePointer, "%.5f\n", a[i]);
    }
    fclose(filePointer);
}

#define VECTOR_EXPORT(...) vectorExport(__VA_ARGS__)
#endif

#endif /* UTILS_H */
