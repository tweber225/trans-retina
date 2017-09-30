#include <new>
using namespace std;
#include "mex.h"
#include "uc480.h"

// in MATLAB calling this should look like:
// set_gain_boost_DCx_cam(hCam, trigMode);

// trigMode indicates which trigger mode to use. No need for an output argument.
// The codes are:
// trigMode = 0: turn trigger off (can query signal at trigger input, but this option causes camera to change to freerun mode)
// trigMode = 1: software triggering
// trigMode = 2: hardware triggering (rising edge)
// trigMode = 3: hardware triggering (falling edge)


// MEX FUNCTION ENTRY
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{
    // Make sure we have enough inputs
    if (nrhs != 2)
        mexErrMsgTxt("Set gain boost function is missing arguments!");
    
    // Declare some variables
    int trigMode;
        
    // Get camera handle
    HCAM hCam = *(HCAM *)mxGetPr(prhs[0]);
       
    // Gather desired state of gain boost
    trigMode = (int)mxGetScalar(prhs[1]);

    // Set gain boost on camera
    if (trigMode == 0) {
        if (is_SetExternalTrigger(hCam, IS_SET_TRIGGER_OFF) != IS_SUCCESS)
            mexErrMsgTxt("Could not set trigger to off");
        mexPrintf("External trigger is off \n");
    } else if (trigMode == 1) {
        if (is_SetExternalTrigger(hCam, IS_SET_TRIGGER_SOFTWARE) != IS_SUCCESS)
            mexErrMsgTxt("Could not set trigger to software");
        mexPrintf("Set triggering to software control \n");
    } else if (trigMode == 2) {
        if (is_SetExternalTrigger(hCam, IS_SET_TRIGGER_LO_HI) != IS_SUCCESS)
            mexErrMsgTxt("Could not set trigger to hardware (rising edge)");
        mexPrintf("External trigger is set to hardware (rising edge) \n");
    } else if (trigMode == 3) {
        if (is_SetExternalTrigger(hCam, IS_SET_TRIGGER_HI_LO) != IS_SUCCESS)
            mexErrMsgTxt("Could not set trigger to hardware (falling edge)");
        mexPrintf("External trigger is set to hardware (falling edge) \n");
    }
    mexEvalString("drawnow;");        
    return;
}
        
        