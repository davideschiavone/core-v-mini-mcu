#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

#include "cnn.h"
#include "fxp32.h"
#include "utils.h"

// #define DYN_ALLOCATION
#define COMP_PREC     0.0001f
#define COMP_PREC_I32 512

void compareVectorsFloat(float* a, float* b, int size, float prec) {
    for (int i = 0; i < size; ++i) {
        assert_closef_si(a[i], b[i], prec, i);
    }
}

void compareVectorsFxp(fxp32* a, fxp32* b, int size, float prec) {
    for (int i = 0; i < size; ++i) {
        assert_closei32_si(a[i], b[i], prec, i);
    }
}

// clang-format off
#ifndef DYN_ALLOCATION

// Create all arays statically
float weights1[] = { -0.12116f, 0.15478f, 0.15130f, -0.15055f, -0.10036f, 0.14400f, -0.00204f, -0.03408f, -0.18936f, 0.03390f, 0.12200f, -0.13891f, 0.05332f, -0.21001f, -0.18876f, -0.06263f, -0.00274f, -0.14772f, 0.06332f, 0.05349f, -0.05071f, 0.13313f, -0.07974f, -0.06264f, -0.03501f, -0.21790f, 0.05925f, -0.14536f, -0.21762f, 0.08203f, -0.08571f, 0.16886f, 0.12439f, 0.12544f, 0.04466f, -0.16849f, 0.04673f, 0.03604f, -0.04811f, 0.21726f, 0.17702f, 0.16138f, 0.08862f, 0.02971f, -0.05572f, -0.07597f, -0.02538f, 0.06561f, -0.08724f, -0.20014f, -0.09443f, -0.13890f, -0.00194f, 0.03216f, 0.14760f, 0.09256f, 0.13031f, -0.09160f, 0.03522f, -0.03609f, -0.08631f, -0.02040f, -0.19688f,};
float weights2[] = { -0.71606f, 0.06657f, -0.07737f,};
float xin[] = { -1.30298f, -0.96491f, -0.51415f, -0.17608f, 0.27468f, 0.50006f, 0.04930f, -0.73953f, -0.96491f, -1.97912f, -2.65526f, -2.31719f, -2.54257f, -2.88064f, -3.21871f, -2.76795f, -2.31719f, -2.20450f, 1.17620f, 1.51427f, 0.95082f, 0.38737f, -0.17608f, 0.04930f, 0.61275f, 0.61275f, 0.50006f, 0.50006f, 0.50006f, -0.17608f, -0.40146f, -0.73953f, -0.73953f, -0.73953f, -0.85222f, -0.73953f, -0.85222f, -0.73953f, -0.17608f, 0.27468f, 0.50006f, 0.61275f, 0.95082f, 1.06351f, 1.06351f, 0.83813f, 0.50006f, 0.16199f, 0.04930f, 0.04930f, 0.50006f, 0.50006f, 0.72544f, 0.83813f, 0.83813f, 0.61275f, 0.04930f, -0.06339f, 0.04930f, 0.61275f, 0.83813f, 1.06351f, 0.95082f, 0.72544f, 0.61275f, 0.38737f, 0.27468f, 0.50006f, 0.50006f, 0.38737f, 0.27468f, 0.27468f, 0.72544f, 0.61275f, 0.50006f, 0.50006f, 0.38737f, 0.04930f, 0.04930f, 0.38737f, 0.38737f, -0.06339f, -0.17608f, -0.17608f, -0.06339f, -0.17608f, -0.51415f, -0.73953f, -0.96491f, -0.73953f, -0.62684f, -0.62684f, 0.16199f, 0.83813f, 1.06351f, 1.28889f, 1.17620f, 0.61275f, 0.38737f, 0.27468f, 0.16199f, 0.38737f, 0.50006f, 0.50006f, 0.38737f, 0.27468f, 0.38737f, 0.50006f, 0.61275f, 0.50006f, 0.50006f, 0.61275f, 0.61275f, 0.16199f, -0.06339f, -0.06339f, -0.06339f, 0.04930f, 0.04930f, -0.17608f, -0.40146f, -0.62684f, -0.73953f, -0.62684f, -0.17608f, 0.16199f, 0.61275f, 0.61275f, 0.72544f, 0.50006f, 0.50006f, 0.27468f, 0.27468f, 0.27468f, 0.38737f, 0.50006f, 0.50006f, 0.38737f, 0.38737f, 0.38737f, 0.27468f, 0.16199f, 0.04930f, 0.27468f, 0.50006f, 0.61275f, 0.72544f, 0.61275f, 0.50006f, -0.06339f, -0.28877f, -0.17608f, -0.06339f, 0.04930f, -0.06339f, -0.17608f, -0.40146f, -0.62684f, -0.62684f, -0.40146f, -0.06339f, 0.27468f, 0.72544f, 0.95082f, 1.06351f, 0.72544f, 0.50006f, 0.38737f, 0.27468f, 0.27468f, 0.27468f, 0.38737f, 0.38737f, 0.27468f, -0.06339f, 0.04930f, 0.27468f, 0.38737f, 0.61275f, 0.61275f, 0.27468f, 0.38737f, 0.50006f, 0.61275f, 0.38737f, -0.06339f, -0.17608f, 0.04930f, 0.27468f, 0.38737f, 0.16199f, -0.06339f, -0.28877f, -0.28877f, -0.40146f, -0.40146f, -0.17608f, 0.16199f, 0.38737f, 0.95082f, 1.17620f, 1.17620f, 0.95082f, 0.27468f, 0.04930f, -0.06339f, 0.16199f, 0.27468f, 0.04930f, -0.28877f, -0.28877f, -0.28877f, -0.17608f, -0.28877f, -0.73953f, -0.85222f, -0.85222f, -0.51415f, -0.17608f, 0.38737f, 0.61275f, 0.72544f, 0.83813f, 0.95082f, 1.06351f, 1.06351f, 0.95082f, 0.95082f, 0.50006f, 0.38737f, 0.04930f, 0.16199f, 0.27468f, -0.40146f, -1.19029f, -2.09181f, -1.86643f, -0.28877f, -2.65526f, -9.75473f, -2.65526f, -1.07760f, -0.06339f, 0.16199f, 0.61275f, 0.38737f, 0.04930f, 0.27468f, 0.04930f, -0.51415f, -0.62684f, -0.51415f, -0.51415f, -0.85222f, -1.19029f, -1.19029f, 0.33916f, 0.92881f, 0.92881f, 0.63399f, -0.25048f, -0.76643f, -1.65090f, -2.09313f, -2.09313f, -1.79831f, -1.65090f, -1.94572f, -2.01942f, -1.06125f, -0.39790f, 1.00251f, 3.72963f, 3.36110f, 1.07622f, 1.07622f, 0.85510f, 0.63399f, -0.17678f, -0.61901f, -1.35607f, -1.65090f, -1.72460f, -1.50348f, -1.28237f, -0.54531f, -0.25048f, 0.48657f, 1.14993f, 1.37104f, 1.66587f, 2.25551f, 1.73957f, 1.07622f, 0.70769f, 0.41287f, 0.19175f, -0.17678f, -0.61901f, -1.57719f, -1.79831f, -1.65090f, -1.28237f, -0.54531f, -0.17678f, 0.56028f, 1.07622f, 1.37104f, 1.59216f, 1.51846f, 1.73957f, 1.44475f, 0.48657f, 0.26546f, 0.19175f, 0.85510f, 0.56028f, -0.25048f, -0.61901f, -0.76643f, -0.91384f, -1.20866f, -0.98754f, -0.61901f, -0.02937f, 0.26546f, 1.07622f, 1.22363f, 1.81328f, 1.44475f, 0.04434f, -0.10307f, 0.33916f, -0.02937f, -0.25048f, -0.61901f, -0.54531f, -0.47160f, -0.32419f, -0.25048f, -0.02937f, 0.48657f, 0.85510f, 1.00251f, 1.37104f, 0.04434f, -0.69272f, -0.25048f, 0.56028f, 0.26546f, 0.04434f, 0.33916f, 0.26546f, -0.32419f, -0.32419f, -0.25048f, -0.17678f, 0.41287f, 0.78140f, 0.92881f, 1.44475f, 1.14993f, -0.10307f, -0.32419f, 0.19175f, 0.26546f, -0.02937f, -0.54531f, -0.76643f, -0.76643f, -0.76643f, -0.69272f, -0.54531f, 0.04434f, 0.19175f, 0.63399f, 0.70769f, 1.07622f, 0.85510f, 0.19175f, 0.11804f, 0.33916f, 0.63399f, 0.56028f, 0.11804f, -0.17678f, -0.47160f, -0.47160f, -0.61901f, -0.69272f, -0.47160f, -0.17678f, 0.04434f, 1.00251f, 1.22363f, 1.51846f, 1.51846f, 1.07622f, -0.32419f, -0.47160f, -0.02937f, -0.32419f, -0.54531f, -0.98754f, -1.13495f, -0.98754f, -0.98754f, -0.69272f, -0.39790f, 0.26546f, 0.70769f, 0.70769f, 0.92881f, 1.59216f, 0.41287f, 0.11804f, 0.33916f, 0.41287f, 0.56028f, 0.04434f, -0.17678f, -0.39790f, -0.61901f, -1.06125f, -1.06125f, -0.76643f, -0.54531f, 0.11804f, 0.85510f, 1.07622f, 1.51846f, 1.96069f, 1.51846f, 0.63399f, -0.54531f, 0.11804f, 0.11804f, -0.39790f, -0.61901f, -0.91384f, -0.98754f, -1.06125f, -0.98754f, -0.47160f, -0.17678f, 0.04434f, 0.56028f, 0.70769f, 0.92881f, 1.29734f, 1.73957f, 1.00251f, -0.69272f, -0.17678f, 0.11804f, 0.33916f, 0.04434f, -0.54531f, -0.84013f, -1.06125f, -1.28237f, -1.79831f, -1.57719f, -1.28237f, -0.54531f, 0.04434f, 0.63399f, 0.78140f, 1.44475f, 1.66587f, 2.18181f, 2.03440f, 1.44475f, 0.33916f, 0.48657f, 0.63399f, 0.41287f, -0.32419f, -0.47160f, -0.39790f, -0.84013f, -1.06125f, -1.35607f, -1.42978f, -1.50348f, -1.57719f, -1.42978f, -1.28237f, -1.20866f, -0.84013f, -0.69272f, -0.69272f, -0.69272f, -0.17678f, 0.48657f, 1.51846f, 1.00251f, 0.56028f, -0.02937f, 0.33916f, 0.33916f, 0.33916f, -0.10307f, -0.54531f, -1.20866f, -1.50348f, -1.42978f, -1.42978f, -1.35607f, -1.06125f, -0.84013f, 0.04434f, 1.10447f, 1.23962f, 0.69900f, 0.42869f, -0.11193f, -0.24708f, -0.65255f, -0.78770f, -1.05801f, -1.19317f, -0.92286f, -0.24708f, -0.24708f, 0.56385f, 0.96931f, 0.96931f, 0.29354f, 1.64509f, 2.18571f, 0.69900f, -0.51739f, -0.92286f, -1.32832f, -1.19317f, -0.65255f, -0.24708f, -0.24708f, -0.38224f, -0.65255f, -1.32832f, -1.32832f, -1.19317f, -1.32832f, -1.59863f, -2.13925f, -2.27441f, -2.13925f, -1.32832f, -0.92286f, -1.32832f, -0.78770f, -0.38224f, -0.38224f, -0.24708f, -0.11193f, 0.02323f, 0.15838f, 0.83416f, 1.23962f, 1.91540f, 2.45602f, 2.86148f, 3.40211f, 3.40211f, 2.59117f, 2.45602f, 1.64509f, 1.23962f, 0.42869f, 0.02323f, -0.11193f, -0.51739f, -0.38224f, -0.24708f, -0.51739f, -0.92286f, -0.92286f, -0.65255f, -0.11193f, 0.15838f, 0.69900f, 0.69900f, -0.11193f, -0.11193f, 0.69900f, 0.69900f, 0.15838f, 0.29354f, 0.15838f, 0.15838f, 0.29354f, 0.42869f, 0.29354f, 0.15838f, 0.02323f, 0.15838f, 0.29354f, 0.15838f, 0.56385f, 0.69900f, 0.56385f, 0.56385f, 0.42869f, 0.02323f, -0.11193f, 0.15838f, 0.15838f, -0.24708f, -0.51739f, -0.92286f, -1.05801f, -0.78770f, -0.65255f, -0.51739f, -0.51739f, -0.38224f, 0.29354f, 0.29354f, 0.42869f, 0.29354f, 0.15838f, 0.02323f, 0.15838f, 0.15838f, 0.02323f, -0.51739f, -0.51739f, -0.11193f, 0.02323f, 0.15838f, 0.15838f, 0.15838f, 1.10447f, 0.83416f, 0.42869f, 0.29354f, 0.02323f, 0.02323f, -0.24708f, -0.38224f, -0.38224f, -0.65255f, -0.78770f, -1.19317f, -0.92286f, -0.65255f, -0.51739f, -0.24708f, -0.24708f, -0.24708f, -0.11193f, 0.29354f, 1.10447f, 0.83416f, 0.69900f, 0.56385f, 0.42869f, 0.29354f, 0.29354f, 0.02323f, 0.02323f, -0.24708f, -0.11193f, 0.29354f, 0.42869f, 0.56385f, 0.42869f, 0.69900f, 1.23962f, 0.96931f, 0.69900f, 0.56385f, 0.29354f, -0.24708f, -0.38224f, -0.38224f, -0.38224f, -0.92286f, -1.05801f, -1.32832f, -1.32832f, -0.92286f, -0.51739f, -0.38224f, -0.11193f, 0.02323f, 0.02323f, 0.29354f, 0.83416f, 0.42869f, 0.29354f, 0.15838f, 0.15838f, 0.15838f, 0.15838f, 0.15838f, 0.02323f, 0.02323f, 0.29354f, 0.42869f, 0.56385f, 0.56385f, 0.56385f, 0.56385f, 1.10447f, 1.37478f, 0.56385f, 0.42869f, 0.42869f, 0.02323f, -0.24708f, -0.51739f, -0.65255f, -0.65255f, -0.92286f, -1.46348f, -1.46348f, -1.32832f, -0.92286f, -0.78770f, -0.78770f, -0.65255f, -0.24708f, -0.11193f, 0.02323f, -0.51739f, -0.51739f, 0.29354f, 0.29354f, 0.42869f, 0.29354f, -0.24708f, -0.24708f, -0.24708f, -0.24708f, -0.38224f, -0.38224f, -0.51739f, -0.38224f, -0.24708f, 0.15838f, 0.69900f, 0.96931f, 1.10447f, 0.83416f, 0.83416f, 0.83416f, 1.23962f, 2.18571f, 7.18645f, 1.78024f, 0.29354f, -1.46348f, -2.00410f, -1.59863f, -1.59863f, -1.05801f, -0.92286f, -1.32832f, -1.19317f, -1.05801f, -1.05801f, -1.32832f, -1.19317f, -0.92286f, -0.78770f,};
float xout[] = { 0.39249f, 0.48451f, 0.73383f, 0.73852f, 1.10356f, 1.51326f, 1.76721f, 1.83251f, 1.31946f, 0.81513f, 0.02872f, 0.09573f, -0.31142f, -1.19899f, -1.17897f, -1.59128f, -1.68418f, -1.58064f, -1.61839f, -0.72027f, -0.35841f, 0.28717f, 1.03874f, 1.20660f, 1.62155f, 1.03099f, 0.66879f, 0.72900f, 0.17669f, -0.18862f, -0.35105f, -0.40824f, -0.50307f, -0.60400f, -0.51233f, -0.42268f, -0.19640f, -0.11939f, -0.08316f, 0.09401f, -0.03073f, 0.05474f, 0.00948f, -0.14916f, -0.29699f, -0.46144f, -0.41988f, -0.36489f, -0.28950f, -0.25506f, -0.41477f, -0.55599f, -0.60255f, -0.37059f, -0.06804f, 0.10718f, 0.32548f, 0.28716f, 0.30881f, 0.11494f, 0.19378f, 0.36549f, 0.49032f, 0.39248f, -0.11330f, -0.16019f, -0.25388f, -0.31549f, -0.40915f, -0.69023f, -0.56602f, -0.27259f, -0.03218f, 0.30087f, 0.40573f, 0.69364f, 0.80954f, 0.71345f, 0.81998f, 0.72108f, 0.49698f, 0.16719f, -0.10408f, -0.19166f, -0.49458f, -0.48501f, -0.35172f, -0.08854f, 0.20221f, 0.22341f, 0.01684f, -0.12514f, -0.43663f, -0.55029f, -0.36411f, -0.09131f, -0.07201f, -0.16178f, -0.05504f, 0.10212f, -0.12362f, -0.37001f, -0.33644f, -0.23595f, -0.00672f, 0.11853f, 0.06942f, 0.20967f, 0.21001f, 0.23882f, 0.36883f, 0.66184f, 0.71750f, 0.42784f, 0.21827f, 0.07058f, -0.03356f, -0.28731f, -0.41314f, -0.34149f, -0.14244f, 0.07088f, 0.01262f, -0.05669f, -0.19078f, -0.33944f, -0.39268f, -0.18032f, 0.07529f, 0.33591f, 0.39141f, 0.32471f, 0.16026f, -0.03295f, -0.25818f, -0.64155f, -0.79985f, -0.93584f, -0.66718f, -0.20500f, 0.17531f, 0.48883f, 0.47296f, 0.40285f, 0.35651f, 0.18949f, 0.29055f, 0.61037f, 0.46581f, 0.27488f, -0.01284f, -0.15280f, -0.17538f, -0.58741f, -0.57524f, -0.47580f, -0.21400f, -0.06589f, -0.10277f, -0.08980f, -0.12787f, -0.20503f, -0.26596f, -0.03148f, 0.32823f, 0.54433f, 0.48218f, 0.34929f, 0.02126f, -0.20263f, -0.49552f, -0.67534f, -0.62950f, -0.68360f, -0.35470f, -0.08379f, 0.14763f, 0.26742f, 0.29058f, 0.28133f, 0.20008f, 0.14494f, 0.41903f, 0.54173f, 0.52405f, 0.29799f, -0.07209f, -0.14607f, -0.46453f, -0.58305f, -0.57501f, -0.69478f, -0.46508f, -0.23234f, 0.07366f, 0.14385f, 0.05992f, -0.20362f, -0.39168f, -0.48250f, -0.07809f, 0.42712f, 0.71610f, 0.81517f, 0.82542f, 0.97280f, 0.77453f, 0.36336f, 0.04949f, -0.26119f, -0.45929f, -0.60788f, -0.69065f, -0.31942f, -0.13976f, 0.09962f, 0.01459f, -0.23469f, -0.43849f, -0.63786f, -0.63111f, -0.59381f, -0.51142f, -0.44169f, -0.36079f, 0.11435f, 0.52288f, 0.56995f, 0.72460f, 1.52536f, 1.96464f, 1.74206f, 0.39785f, 0.85132f, 0.47575f, -0.53417f, 0.15703f, 0.37793f, 0.68815f, 0.26998f, -0.36431f, -0.00991f, -1.89429f, -1.31357f, -0.37315f, -0.73792f, 0.22693f, -0.13869f, -0.04304f, 0.91745f, 0.28913f, 0.00824f, -0.09014f, -0.22067f, -0.39314f, -0.55479f,};
float ppg[] = { 0.46327f, 0.32949f, 0.07201f, -0.29688f, -0.62103f, -0.64516f, -0.27495f, 0.24132f, 0.54530f, 0.49617f, 0.18035f, -0.26311f, -0.72587f, -1.14389f, -1.46848f, -1.61454f, -1.46102f, -1.00265f, -0.46707f, -0.07844f, 0.23123f, 0.65189f, 1.15061f, 1.54846f, 1.77962f, 1.84234f, 1.68487f, 1.28177f, 0.72119f, 0.13912f, -0.37057f, -0.75262f, -0.92106f, -0.80702f, -0.53024f, -0.32013f, -0.19117f, 0.04964f, 0.44617f, 0.83831f, 1.10851f, 1.21904f, 1.13570f, 0.90103f, 0.59486f, 0.20316f, -0.28679f, -0.74780f, -1.03247f, -1.10836f, -1.04695f, -0.96712f, -0.96142f, -0.95659f, -0.78377f, -0.44865f, -0.14380f, 0.03078f, 0.13561f, 0.21939f, 0.30010f, 0.43695f, 0.63083f, 0.75716f, 0.72338f, 0.56635f, 0.33563f, 0.00841f, -0.39163f, -0.67148f, -0.58419f, -0.11046f, 0.53038f, 1.13658f, 1.57872f, 1.68092f, 1.36379f, 0.82866f, 0.33212f, -0.07932f, -0.46620f, -0.83991f, -1.20091f, -1.53734f, -1.77377f, -1.83781f, -1.73824f, -1.49787f, -1.13511f, -0.75526f, -0.49339f, -0.37189f, -0.32057f, -0.27758f, -0.18547f, -0.01659f, 0.15754f, 0.23167f, 0.19878f, 0.11763f, 0.00490f, -0.15038f, -0.30127f, -0.28197f, 0.12903f, 0.97034f, 1.93402f, 2.56521f, 2.62969f, 2.21650f, 1.58793f, 0.99797f, 0.55670f, 0.18079f, -0.25433f, -0.73201f, -1.14652f, -1.47374f, -1.73648f, -1.85492f, -1.69262f, -1.25530f, -0.75262f, -0.41400f, -0.28372f, -0.25390f, -0.23898f, -0.23591f, -0.24337f, -0.23372f, -0.20477f, -0.17889f, -0.16924f, -0.19249f, -0.29381f, -0.44251f, -0.44909f, -0.11573f, 0.54179f, 1.30633f, 1.97086f, 2.42310f, 2.54723f, 2.23185f, 1.54012f, 0.72251f, -0.00212f, -0.55436f, -0.94782f, -1.27811f, -1.66060f, -2.05800f, -2.24311f, -2.00405f, -1.36847f, -0.59866f, 0.01893f, 0.34660f, 0.38344f, 0.21808f, 0.01586f, -0.09994f, -0.15038f, -0.19249f, -0.21223f, -0.21924f, -0.30873f, -0.49646f, -0.61182f, -0.48769f, -0.15257f, 0.26633f, 0.70189f, 1.12386f, 1.46906f, 1.69321f, 1.80988f, 1.82217f, 1.65329f, 1.23659f, 0.63917f, -0.00124f, -0.61752f, -1.16319f, -1.48558f, -1.43953f, -1.09388f, -0.68244f, -0.39163f, -0.23328f, -0.11704f, 0.00753f, 0.09087f, 0.11280f, 0.12552f, 0.13561f, 0.09613f, -0.01616f, -0.26618f, -0.68815f, -0.99387f, -0.72192f, 0.13210f, 1.01376f, 1.45108f, 1.42871f, 1.11026f, 0.58521f, -0.03677f, -0.55261f, -0.79868f, -0.76710f, -0.55568f, -0.30302f, -0.15871f, -0.13897f, -0.00300f, 0.50143f, 1.26905f, 1.93840f, 2.29326f, 2.33712f, 2.12044f, 1.71207f, 1.24931f, 0.88787f, 0.68522f, 0.52337f, 0.20053f, -0.38417f, -1.12722f, -1.75578f, -2.00668f, -1.83562f, -1.42110f, -0.94255f, -0.41356f, 0.19527f, 0.57732f, 0.19132f, -0.83114f, -1.50488f, -1.29566f, -0.74561f, -0.39163f, -0.17714f, -0.09511f, -0.24337f, -0.29601f, 0.11807f, 0.73567f, 1.00543f, 0.84269f, 0.53345f, 0.17465f, -0.34645f,};
float ppgf[] = { 0.07078f, -0.15502f, -0.66182f, -1.03541f, -1.72459f, -2.15842f, -2.04216f, -1.59119f, -0.77417f, -0.31896f, 0.15163f, -0.35884f, -0.41444f, 0.05510f, -0.28951f, -0.02326f, 0.22316f, 0.57799f, 1.15132f, 0.64183f, 0.58965f, 0.36472f, 0.11188f, 0.34186f, 0.15807f, 0.81135f, 1.01608f, 0.55277f, 0.54450f, 0.32774f, -0.01952f, -0.34439f, -0.41799f, -0.20301f, -0.01791f, 0.10255f, 0.00523f, 0.16903f, 0.52932f, 0.74430f, 1.13924f, 1.16430f, 1.12622f, 1.05019f, 0.89185f, 0.66460f, 0.13308f, -0.38291f, -0.74298f, -0.85330f, -0.63218f, -0.41113f, -0.35886f, -0.58600f, -0.71572f, -0.55583f, -0.46928f, -0.25638f, -0.17320f, 0.10445f, 0.10632f, 0.07146f, 0.14051f, 0.36468f, 0.83668f, 0.72655f, 0.58951f, 0.32389f, 0.01752f, 0.01875f, -0.01817f, 0.16213f, 0.56257f, 0.83571f, 1.17299f, 0.98729f, 0.55425f, 0.11521f, -0.48786f, -0.80040f, -0.96317f, -1.00710f, -1.09683f, -1.34569f, -1.27919f, -1.35280f, -1.38652f, -1.40933f, -1.33732f, -0.97867f, -0.51023f, -0.24675f, 0.11606f, 0.27271f, 0.17864f, 0.07471f, 0.22955f, 0.39345f, 0.25381f, 0.01551f, 0.12852f, 0.21963f, 0.03517f, -0.04602f, 0.13576f, 0.85180f, 1.86460f, 2.35555f, 2.41968f, 1.97768f, 1.21910f, 0.33612f, -0.16080f, -0.24705f, -0.47261f, -0.80259f, -1.11296f, -1.18643f, -1.32334f, -1.51343f, -1.55018f, -1.32618f, -0.76524f, -0.35730f, -0.09294f, 0.08555f, 0.15369f, -0.05559f, -0.31866f, -0.56963f, -0.59618f, -0.50360f, -0.32950f, -0.15953f, -0.03563f, 0.19904f, 0.35076f, 0.82012f, 1.20897f, 1.51133f, 1.79555f, 1.93426f, 2.07427f, 1.82900f, 1.18362f, 0.53301f, -0.29267f, -1.16473f, -1.41363f, -1.55299f, -1.64776f, -1.90520f, -2.06773f, -1.41664f, -0.79323f, -0.12286f, 0.23294f, 0.41249f, 0.48621f, 0.30788f, 0.14374f, 0.10509f, 0.11559f, -0.16101f, -0.54046f, -0.76358f, -0.79090f, -0.84575f, -0.63308f, -0.28506f, 0.34295f, 0.94167f, 1.33139f, 1.80746f, 1.82377f, 1.77700f, 1.66225f, 1.55474f, 1.36271f, 0.95526f, 0.43909f, -0.14618f, -1.03655f, -1.70492f, -2.00963f, -1.73752f, -1.02179f, -0.53637f, 0.07291f, 0.34977f, 0.45797f, 0.70231f, 0.55596f, 0.34514f, 0.05186f, -0.00824f, 0.03621f, 0.18746f, 0.12550f, -0.20564f, -0.91578f, -1.14904f, -0.58400f, 0.19859f, 0.62565f, 0.45591f, 0.33573f, 0.22186f, -0.08626f, -0.29142f, -0.33939f, -0.15922f, 0.13497f, 0.01640f, -0.01895f, -0.23859f, -0.01758f, 0.73613f, 1.70753f, 2.57627f, 2.92437f, 2.93094f, 2.63186f, 2.15376f, 1.61009f, 0.77352f, 0.16235f, -0.04659f, -0.52407f, -1.90953f, -3.09186f, -3.49785f, -2.40454f, -2.68693f, -1.89685f, -0.40838f, -0.57059f, -0.18267f, -0.11083f, -0.07867f, -0.46683f, -1.49498f, 0.59864f, 0.56797f, -0.01848f, 0.56078f, -0.32204f, -0.10468f, -0.25296f, -0.79938f, 0.44654f, 0.99719f, 0.93283f, 0.75412f, 0.56779f, 0.20835f,};
int32_t xin_fxp[] = { -10930188, -8094251, -4313003, -1477066, 2304182, 4194807, 413558, -6203627, -8094251, -16602062, -22273936, -19437998, -21328624, -24164560, -27000496, -23219248, -19437998, -18492686, 9866681, 12702617, 7976056, 3249495, -1477066, 413558, 5140119, 5140119, 4194807, 4194807, 4194807, -1477066, -3367690, -6203627, -6203627, -6203627, -7148939, -6203627, -7148939, -6203627, -1477066, 2304182, 4194807, 5140119, 7976056, 8921368, 8921368, 7030744, 4194807, 1358870, 413558, 413558, 4194807, 4194807, 6085432, 7030744, 7030744, 5140119, 413558, -531753, 413558, 5140119, 7030744, 8921368, 7976056, 6085432, 5140119, 3249495, 2304182, 4194807, 4194807, 3249495, 2304182, 2304182, 6085432, 5140119, 4194807, 4194807, 3249495, 413558, 413558, 3249495, 3249495, -531753, -1477066, -1477066, -531753, -1477066, -4313003, -6203627, -8094251, -6203627, -5258315, -5258315, 1358870, 7030744, 8921368, 10811993, 9866681, 5140119, 3249495, 2304182, 1358870, 3249495, 4194807, 4194807, 3249495, 2304182, 3249495, 4194807, 5140119, 4194807, 4194807, 5140119, 5140119, 1358870, -531753, -531753, -531753, 413558, 413558, -1477066, -3367690, -5258315, -6203627, -5258315, -1477066, 1358870, 5140119, 5140119, 6085432, 4194807, 4194807, 2304182, 2304182, 2304182, 3249495, 4194807, 4194807, 3249495, 3249495, 3249495, 2304182, 1358870, 413558, 2304182, 4194807, 5140119, 6085432, 5140119, 4194807, -531753, -2422378, -1477066, -531753, 413558, -531753, -1477066, -3367690, -5258315, -5258315, -3367690, -531753, 2304182, 6085432, 7976056, 8921368, 6085432, 4194807, 3249495, 2304182, 2304182, 2304182, 3249495, 3249495, 2304182, -531753, 413558, 2304182, 3249495, 5140119, 5140119, 2304182, 3249495, 4194807, 5140119, 3249495, -531753, -1477066, 413558, 2304182, 3249495, 1358870, -531753, -2422378, -2422378, -3367690, -3367690, -1477066, 1358870, 3249495, 7976056, 9866681, 9866681, 7976056, 2304182, 413558, -531753, 1358870, 2304182, 413558, -2422378, -2422378, -2422378, -1477066, -2422378, -6203627, -7148939, -7148939, -4313003, -1477066, 3249495, 5140119, 6085432, 7030744, 7976056, 8921368, 8921368, 7976056, 7976056, 4194807, 3249495, 413558, 1358870, 2304182, -3367690, -9984876, -17547374, -15656750, -2422378, -22273936, -81828608, -22273936, -9039564, -531753, 1358870, 5140119, 3249495, 413558, 2304182, 413558, -4313003, -5258315, -4313003, -4313003, -7148939, -9984876, -9984876, 2845080, 7791423, 7791423, 5318293, -2101178, -6429281, -13848753, -17558448, -17558448, -15085318, -13848753, -16321882, -16940122, -8902410, -3337827, 8409663, 31286404, 28194950, 9027988, 9027988, 7173098, 5318293, -1482938, -5192632, -11375540, -13848753, -14466993, -12612104, -10757299, -4574392, -2101178, 4081645, 9646312, 11501117, 13974330, 18920590, 14592571, 9027988, 5936534, 3463404, 1608515, -1482938, -5192632, -13230429, -15085318, -13848753, -10757299, -4574392, -1482938, 4699969, 9027988, 11501117, 13356006, 12737766, 14592571, 12119441, 4081645, 2226840, 1608515, 7173098, 4699969, -2101178, -5192632, -6429281, -7665845, -10138975, -8284086, -5192632, -246373, 2226840, 9027988, 10264552, 15210895, 12119441, 371950, -864613, 2845080, -246373, -2101178, -5192632, -4574392, -3956067, -2719502, -2101178, -246373, 4081645, 7173098, 8409663, 11501117, 371950, -5810956, -2101178, 4699969, 2226840, 371950, 2845080, 2226840, -2719502, -2719502, -2101178, -1482938, 3463404, 6554858, 7791423, 12119441, 9646312, -864613, -2719502, 1608515, 2226840, -246373, -4574392, -6429281, -6429281, -6429281, -5810956, -4574392, 371950, 1608515, 5318293, 5936534, 9027988, 7173098, 1608515, 990191, 2845080, 5318293, 4699969, 990191, -1482938, -3956067, -3956067, -5192632, -5810956, -3956067, -1482938, 371950, 8409663, 10264552, 12737766, 12737766, 9027988, -2719502, -3956067, -246373, -2719502, -4574392, -8284086, -9520651, -8284086, -8284086, -5810956, -3337827, 2226840, 5936534, 5936534, 7791423, 13356006, 3463404, 990191, 2845080, 3463404, 4699969, 371950, -1482938, -3337827, -5192632, -8902410, -8902410, -6429281, -4574392, 990191, 7173098, 9027988, 12737766, 16447460, 12737766, 5318293, -4574392, 990191, 990191, -3337827, -5192632, -7665845, -8284086, -8902410, -8284086, -3956067, -1482938, 371950, 4699969, 5936534, 7791423, 10882877, 14592571, 8409663, -5810956, -1482938, 990191, 2845080, 371950, -4574392, -7047521, -8902410, -10757299, -15085318, -13230429, -10757299, -4574392, 371950, 5318293, 6554858, 12119441, 13974330, 18302348, 17065784, 12119441, 2845080, 4081645, 5318293, 3463404, -2719502, -3956067, -3337827, -7047521, -8902410, -11375540, -11993864, -12612104, -13230429, -11993864, -10757299, -10138975, -7047521, -5810956, -5810956, -5810956, -1482938, 4081645, 12737766, 8409663, 4699969, -246373, 2845080, 2845080, 2845080, -864613, -4574392, -10138975, -12612104, -11993864, -11993864, -11375540, -8902410, -7047521, 371950, 9264966, 10398686, 5863637, 3596112, -938936, -2072657, -5473986, -6607706, -8875231, -10009035, -7741511, -2072657, -2072657, 4729916, 8131161, 8131161, 2462392, 13800015, 18335064, 5863637, -4340182, -7741511, -11142756, -10009035, -5473986, -2072657, -2072657, -3206461, -5473986, -11142756, -11142756, -10009035, -11142756, -13410280, -17945330, -19079134, -17945330, -11142756, -7741511, -11142756, -6607706, -3206461, -3206461, -2072657, -938936, 194867, 1328587, 6997441, 10398686, 16067540, 20602590, 24003834, 28538968, 28538968, 21736310, 20602590, 13800015, 10398686, 3596112, 194867, -938936, -4340182, -3206461, -2072657, -4340182, -7741511, -7741511, -5473986, -938936, 1328587, 5863637, 5863637, -938936, -938936, 5863637, 5863637, 1328587, 2462392, 1328587, 1328587, 2462392, 3596112, 2462392, 1328587, 194867, 1328587, 2462392, 1328587, 4729916, 5863637, 4729916, 4729916, 3596112, 194867, -938936, 1328587, 1328587, -2072657, -4340182, -7741511, -8875231, -6607706, -5473986, -4340182, -4340182, -3206461, 2462392, 2462392, 3596112, 2462392, 1328587, 194867, 1328587, 1328587, 194867, -4340182, -4340182, -938936, 194867, 1328587, 1328587, 1328587, 9264966, 6997441, 3596112, 2462392, 194867, 194867, -2072657, -3206461, -3206461, -5473986, -6607706, -10009035, -7741511, -5473986, -4340182, -2072657, -2072657, -2072657, -938936, 2462392, 9264966, 6997441, 5863637, 4729916, 3596112, 2462392, 2462392, 194867, 194867, -2072657, -938936, 2462392, 3596112, 4729916, 3596112, 5863637, 10398686, 8131161, 5863637, 4729916, 2462392, -2072657, -3206461, -3206461, -3206461, -7741511, -8875231, -11142756, -11142756, -7741511, -4340182, -3206461, -938936, 194867, 194867, 2462392, 6997441, 3596112, 2462392, 1328587, 1328587, 1328587, 1328587, 1328587, 194867, 194867, 2462392, 3596112, 4729916, 4729916, 4729916, 4729916, 9264966, 11532491, 4729916, 3596112, 3596112, 194867, -2072657, -4340182, -5473986, -5473986, -7741511, -12276560, -12276560, -11142756, -7741511, -6607706, -6607706, -5473986, -2072657, -938936, 194867, -4340182, -4340182, 2462392, 2462392, 3596112, 2462392, -2072657, -2072657, -2072657, -2072657, -3206461, -3206461, -4340182, -3206461, -2072657, 1328587, 5863637, 8131161, 9264966, 6997441, 6997441, 6997441, 10398686, 18335064, 60284312, 14933736, 2462392, -12276560, -16811610, -13410280, -13410280, -8875231, -7741511, -11142756, -10009035, -8875231, -8875231, -11142756, -10009035, -7741511, -6607706,};
int32_t xout_fxp[] = { 3292444, 4064364, 6155812, 6195155, 9257332, 12694145, 14824432, 15372208, 11068433, 6837806, 240920, 803041, -2612380, -10057857, -9889917, -13348624, -14127926, -13259369, -13576039, -6042062, -3006561, 2408956, 8713583, 10121694, 13602547, 8648571, 5610217, 6115295, 1482183, -1582259, -2944820, -3424565, -4220057, -5066719, -4297735, -3545696, -1647522, -1001515, -697596, 788613, -257781, 459192, 79524, -1251244, -2491332, -3870839, -3522208, -3060919, -2428502, -2139598, -3479343, -4663982, -5054556, -3108734, -570760, 899091, 2730324, 2408872, 2590486, 964186, 1625544, 3065952, 4113102, 3292360, -950429, -1343771, -2129699, -2646522, -3432199, -5790069, -4748120, -2286650, -269945, 2523880, 3403510, 5818674, 6790913, 5984852, 6878491, 6048857, 4168970, 1402491, -873086, -1607760, -4148837, -4068558, -2950441, -742727, 1696260, 1874098, 141264, -1049750, -3662718, -4616167, -3054376, -765963, -604063, -1357109, -461708, 856644, -1036999, -3103868, -2822263, -1979292, -56371, 994301, 582337, 1758839, 1761691, 2003367, 3093970, 5551916, 6018826, 3588982, 1830981, 592067, -281521, -2410131, -3465669, -2864625, -1194873, 594584, 105864, -475550, -1600378, -2847429, -3294038, -1512633, 631578, 2817817, 3283385, 2723865, 1344358, -276404, -2165770, -5381711, -6709628, -7850395, -5596711, -1719664, 1470606, 4100603, 3967476, 3379350, 2990622, 1589557, 2437310, 5120154, 3907497, 2305860, -107709, -1281779, -1471194, -4927552, -4825463, -3991299, -1795162, -552725, -862097, -753297, -1072651, -1719916, -2231034, -264073, 2753392, 4566171, 4044819, 2930057, 178341, -1699783, -4156723, -5665162, -5280628, -5734452, -2975439, -702881, 1238410, 2243281, 2437561, 2359967, 1678392, 1215844, 3515078, 4544360, 4396050, 2499721, -604734, -1225324, -3896760, -4890978, -4823533, -5828237, -3901373, -1949009, 617904, 1206701, 502645, -1708088, -3285650, -4047503, -655066, 3582942, 6007082, 6838141, 6924125, 8160438, 6497228, 3048084, 415152, -2191020, -3852803, -5099267, -5793592, -2679489, -1172391, 835673, 122389, -1968722, -3678320, -5350757, -5294134, -4981239, -4290102, -3705164, -3026526, 959237, 4386235, 4781087, 6078385, 12795647, 16480595, 14613458, 3337407, 7141390, 3990880, -4480942, 1317263, 3170306, 5772620, 2264756, -3056053, -83131, -15890456, -11019024, -3130209, -6190121, 1903626, -1163416, -361045, 7696128, 2425398, 69122, -756149, -1851114, -3297897, -4653916,};

float result[256];

float layer1Output[3*256];

fxp32* weights1Fxp[63];
fxp32* weights2Fxp[3];

fxp32 layer1OutputFxp[3*256];

fxp32 resultFxp[256];

#endif
// clang-format on

int main() {
    printf("Running cnn test\n");

    // Create the CNN
    printf("Creating CNN\n");
    Conv2DLayer layer1;
    layer1.dim = (Dim2D){3u, 21u};
    layer1.padding = SAME;
    layer1.weightsFloat = weights1;
    layer1.weightsFxp = weights1Fxp;

    Conv2DLayer layer2;
    layer2.dim = (Dim2D){3u, 1u};
    layer2.padding = VALID;
    layer2.weightsFloat = weights2;
    layer2.weightsFxp = weights2Fxp;

    Cnn cnn;
    cnn.layer1 = &layer1;
    cnn.layer2 = &layer2;
    cnn.inputDim = (Dim2D){3u, 256u};
    cnn.outputDim = (Dim2D){1u, 256u};
    cnn.layer1Output = layer1Output;
    cnn.layer1OutputFxp = layer1OutputFxp;

    // Forward pass
    printf("Forward pass\n");
    Cnn_forwardFloat(&cnn, xin, result);

    printf("Comparing results\n");
    compareVectorsFloat(result, xout, 256, COMP_PREC);
    printf("Test passed\n");

    printf("Test predict method\n");
    Cnn_predictFloat(&cnn, xin, ppg, result);

    compareVectorsFloat(result, ppgf, 256, COMP_PREC);
    printf("Test passed\n");

    // Freeze model
    printf("Freezing model\n");
    Cnn_freezeModel(&cnn);

    printf("Running cnn test with fixed point\n");
    Cnn_forwardFxp(&cnn, xin_fxp, resultFxp);

    printf("Comparing results\n");
    compareVectorsFxp(resultFxp, xout_fxp, 256, COMP_PREC_I32);
    printf("Test passed\n");

    printf("CNN test finished\n");

    return 0;
}