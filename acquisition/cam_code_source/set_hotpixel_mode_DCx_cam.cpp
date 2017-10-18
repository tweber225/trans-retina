#include <new>
using namespace std;
#include "mex.h"
#include "uc480.h"

// in MATLAB calling this should look like:
// set_hotpixel_mode_DCx_cam(hCam, desiredHotPixelMode);

// Before calling this function, need to check whether desiredHotPixelMode is valid!
// desiredHotPixelMode = 0 (no hot pixel correction)
// desiredHotPixelMode = 1 (sensor-based hot pixel correction)

// MEX FUNCTION ENTRY
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{
    // Make sure we have enough inputs
    if (nrhs != 2)
        mexErrMsgTxt("Set hot pixel mode function is missing arguments!");
    
    // Declare some variables
    int desiredHotPixelMode;
        
    // Get camera handle
    HCAM hCam = *(HCAM *)mxGetPr(prhs[0]);
       
    // Gather desired hot pixel setting
    desiredHotPixelMode = (int)mxGetScalar(prhs[1]);
    
    // Set bin size
    if (desiredHotPixelMode == 0) {
        if (is_HotPixel(hCam, IS_HOTPIXEL_DISABLE_CORRECTION, NULL, NULL) != IS_SUCCESS) {
            mexErrMsgTxt("Error disabling hot pixel mode");
        } else {
            mexPrintf("Hot pixel correction disabled \n");
        }
    } else if (desiredHotPixelMode == 1) {
        if (is_HotPixel(hCam, IS_HOTPIXEL_ENABLE_SENSOR_CORRECTION, NULL, NULL) != IS_SUCCESS) {
            mexErrMsgTxt("Error setting sensor hot pixel correction!");
        } else {
            mexPrintf("Sensor-based hot pixel correction enabled \n");
        }
    } else {
        mexErrMsgTxt("Attempt to set invalid hot pixel mode");
    }
    mexEvalString("drawnow;");
    
    return;
}
        
        