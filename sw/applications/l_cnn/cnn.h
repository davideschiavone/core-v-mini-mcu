#ifndef CNN_H
#define CNN_H

#include "conv2dlayer.h"
#include "fxp32.h"

/**
 * @brief a two layer cnn model
 */
typedef struct __Cnn {
    Conv2DLayerHandle layer1;
    Conv2DLayerHandle layer2;
    Dim2D inputDim;
    Dim2D outputDim;
} Cnn;

typedef struct __Cnn* CnnHandle;

CnnHandle Cnn_create(Dim2D inputDim, Dim2D layer1Dim, Dim2D layer2Dim, Conv2DPadding layer1Pad,
                     Conv2DPadding layer2Pad);
void Cnn_destroy(CnnHandle self);

void Cnn_forwardFxp(CnnHandle self, fxp32* input, fxp32* output);
void Cnn_forwardFloat(CnnHandle self, float* input, float* output);

void Cnn_predictFxp(CnnHandle self, fxp32* acc, fxp32* ppg, fxp32* output);
void Cnn_predictFloat(CnnHandle self, float* acc, float* ppg, float* output);

void Cnn_freezeModel(CnnHandle self);

#endif // CNN_H