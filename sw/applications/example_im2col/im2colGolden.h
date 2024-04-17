/*
   Copyright EPFL contributors.
  Licensed under the Apache License, Version 2.0, see LICENSE for details.
  SPDX-License-Identifier: Apache-2.0

  Author: Tommaso Terzano <tommaso.terzano@epfl.ch>

  Info: Header file of im2colGolden, contains activations parameters and the prototypes of both input tensors and golden output.
*/

#ifndef IMAGE_AND_COL_H
#define IMAGE_AND_COL_H

#include <stdint.h>

#define IW 4
#define IH 4
#define CH 3
#define FW 2
#define FH 2
#define STRIDES 1
#define PAD 1

#define BATCH 1

extern const uint32_t input_image[48];
extern const uint32_t golden_im2col[300];

#endif
