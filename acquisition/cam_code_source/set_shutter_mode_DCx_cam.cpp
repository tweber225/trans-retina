#include <new>
using namespace std;
#include "mex.h"
#include "uc480.h"

// in MATLAB calling this should look like:
// set_gain_boost_DCx_cam(hCam, shutterMode);

// shutterMode indicates which shutter mode to use. No need for an output argument.
// The codes are:
// shutterMode = 0: rolling shutter mode
// shutterMode = 1: rolling shutter with global start
// shutterMode = 2: global shutter
// shutterMode = 3: global shutter with alt. timing parameters


// MEX FUNCTION ENTRY
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{
    // Make sure we have enough inputs
    if (nrhs != 2)
        mexErrMsgTxt("Set shutter mode function is missing arguments!");
    
    // Declare some variables
    int shutterMode;
        
    // Get camera handle
    HCAM hCam = *(HCAM *)mxGetPr(prhs[0]);
       
    // Gather desired state of shutter mode
    shutterMode = (int)mxGetScalar(prhs[1]);

    // Set shutter on camera
    if (shutterMode == 0) {
        UINT shutterModeCode = IS_DEVICE_FEATURE_CAP_SHUTTER_MODE_ROLLING;
        if (is_DeviceFeature(hCam, IS_DEVICE_FEATURE_CMD_SET_SHUTTER_MODE, (void*)&shutterModeCode, sizeof(shutterModeCode)) != IS_SUCCESS)
            mexErrMsgTxt("Could not set shutter mode to rolling");
        mexPrintf("Shutter mode set to rolling \n");
    } else if (shutterMode == 1) {
        UINT shutterModeCode = IS_DEVICE_FEATURE_CAP_SHUTTER_MODE_ROLLING_GLOBAL_START;
        if (is_DeviceFeature(hCam, IS_DEVICE_FEATURE_CMD_SET_SHUTTER_MODE, (void*)&shutterModeCode, sizeof(shutterModeCode)) != IS_SUCCESS)
            mexErrMsgTxt("Could not set shutter mode to rolling (global start)");
        mexPrintf("Shutter mode set to rolling (global start) \n");
    } else if (shutterMode == 2) {
        UINT shutterModeCode = IS_DEVICE_FEATURE_CAP_SHUTTER_MODE_GLOBAL;
        if (is_DeviceFeature(hCam, IS_DEVICE_FEATURE_CMD_SET_SHUTTER_MODE, (void*)&shutterModeCode, sizeof(shutterModeCode)) != IS_SUCCESS)
            mexErrMsgTxt("Could not set shutter mode to global");
        mexPrintf("Shutter mode set to global \n");
    } else if (shutterMode == 3) {
        UINT shutterModeCode = IS_DEVICE_FEATURE_CAP_SHUTTER_MODE_GLOBAL_ALTERNATIVE_TIMING;
        if (is_DeviceFeature(hCam, IS_DEVICE_FEATURE_CMD_SET_SHUTTER_MODE, (void*)&shutterModeCode, sizeof(shutterModeCode)) != IS_SUCCESS)
            mexErrMsgTxt("Could not set shutter mode to global (alt. timing)");
        mexPrintf("Shutter mode set to global (alt. timing) \n");
    }
    mexEvalString("drawnow;");        
    return;
}
        
        