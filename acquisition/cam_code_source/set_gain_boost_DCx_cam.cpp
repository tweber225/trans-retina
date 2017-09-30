#include <new>
using namespace std;
#include "mex.h"
#include "uc480.h"

// in MATLAB calling this should look like:
// set_gain_boost_DCx_cam(hCam, gainBoostOn);

// Sets the gain boost status (2X for gainBoostOn=1, 1X for gainBoostOn=0). No need to pass an output argument.

// MEX FUNCTION ENTRY
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{
    // Make sure we have enough inputs
    if (nrhs != 2)
        mexErrMsgTxt("Set gain boost function is missing arguments!");
    
    // Declare some variables
    INT gainBoostOn;
        
    // Get camera handle
    HCAM hCam = *(HCAM *)mxGetPr(prhs[0]);
       
    // Gather desired state of gain boost
    gainBoostOn = (INT)mxGetScalar(prhs[1]);

    // Set gain boost on camera
    if (gainBoostOn == 1) {
        if (is_SetGainBoost(hCam, IS_SET_GAINBOOST_ON) != IS_SUCCESS)
            mexErrMsgTxt("Could not set gain boost");
        mexPrintf("Gain boost is on \n");
    } else {
        if (is_SetGainBoost(hCam, IS_SET_GAINBOOST_OFF) != IS_SUCCESS)
            mexErrMsgTxt("Could not set gain boost");
        mexPrintf("Gain boost is off \n");
    }
                
    return;
}
        
        