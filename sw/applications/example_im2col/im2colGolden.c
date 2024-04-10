#include "im2colGolden.h"

const uint32_t input_image[16] = {
    64053, 2048, 272, 39321,
    14584, 33502, 13787, 46466,
    17933, 41124, 27, 62514,
    8449, 20759, 55974, 30776
};
const uint32_t golden_im2col[100] = {
    0, 0, 0, 0, 0, 0, 64053, 2048, 272, 39321, 0, 14584, 33502, 13787, 46466, 0, 17933, 41124, 27, 62514, 0, 8449, 20759, 55974, 30776,
    0, 0, 0, 0, 0, 64053, 2048, 272, 39321, 0, 14584, 33502, 13787, 46466, 0, 17933, 41124, 27, 62514, 0, 8449, 20759, 55974, 30776, 0,
    0, 64053, 2048, 272, 39321, 0, 14584, 33502, 13787, 46466, 0, 17933, 41124, 27, 62514, 0, 8449, 20759, 55974, 30776, 0, 0, 0, 0, 0,
    64053, 2048, 272, 39321, 0, 14584, 33502, 13787, 46466, 0, 17933, 41124, 27, 62514, 0, 8449, 20759, 55974, 30776, 0, 0, 0, 0, 0, 0
};
