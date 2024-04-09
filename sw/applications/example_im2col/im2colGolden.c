#include "im2colGolden.h"

const uint32_t input_image[32] = {
    31911, 21070, 7519, 35018,
    11013, 7773, 17586, 17319,
    47536, 25818, 41611, 27554,
    41929, 30331, 4629, 59579,
    24452, 23842, 53261, 32497,
    49097, 31878, 2121, 48484,
    43116, 58409, 16724, 63937,
    5111, 27192, 6328, 29532
};
const uint32_t golden_im2col[392] = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 31911, 21070, 7519, 35018, 0, 0, 0, 11013, 7773, 17586, 17319, 0, 0, 0, 47536, 25818, 41611, 27554, 0, 0, 0, 41929, 30331, 4629, 59579, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 31911, 21070, 7519, 35018, 0, 0, 0, 11013, 7773, 17586, 17319, 0, 0, 0, 47536, 25818, 41611, 27554, 0, 0, 0, 41929, 30331, 4629, 59579, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 31911, 21070, 7519, 35018, 0, 0, 0, 11013, 7773, 17586, 17319, 0, 0, 0, 47536, 25818, 41611, 27554, 0, 0, 0, 41929, 30331, 4629, 59579, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 31911, 21070, 7519, 35018, 0, 0, 0, 11013, 7773, 17586, 17319, 0, 0, 0, 47536, 25818, 41611, 27554, 0, 0, 0, 41929, 30331, 4629, 59579, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24452, 23842, 53261, 32497, 0, 0, 0, 49097, 31878, 2121, 48484, 0, 0, 0, 43116, 58409, 16724, 63937, 0, 0, 0, 5111, 27192, 6328, 29532, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 24452, 23842, 53261, 32497, 0, 0, 0, 49097, 31878, 2121, 48484, 0, 0, 0, 43116, 58409, 16724, 63937, 0, 0, 0, 5111, 27192, 6328, 29532, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 24452, 23842, 53261, 32497, 0, 0, 0, 49097, 31878, 2121, 48484, 0, 0, 0, 43116, 58409, 16724, 63937, 0, 0, 0, 5111, 27192, 6328, 29532, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 24452, 23842, 53261, 32497, 0, 0, 0, 49097, 31878, 2121, 48484, 0, 0, 0, 43116, 58409, 16724, 63937, 0, 0, 0, 5111, 27192, 6328, 29532, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};
