#include <new>
using namespace std;
#include "mex.h"
#include "uc480.h"

// in MATLAB calling this should look like:
// set_exp_time_DCx_cam(hCam, newExposureTime);

// Before calling this function, need to check whether desiredExpTime is valid!
// Function should return the actual set exposure time

// MEX FUNCTION ENTRY
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{
    // Make sure we have enough inputs
    if (nrhs != 2)
        mexErrMsgTxt("Set exposure function is missing arguments!");
    
    // Declare some variables
    double desiredExpTime;
    
    // Get camera handle
    HCAM hCam = *(HCAM *)mxGetPr(prhs[0]);
    
    // Get desired exposure time
    desiredExpTime = (double)mxGetScalar(prhs[1]);
        
    // Set exposure time
    INT nRet = is_Exposure(hCam, IS_EXPOSURE_CMD_SET_EXPOSURE, (void*)&desiredExpTime, sizeof(desiredExpTime));
    if (nRet != IS_SUCCESS) {
        mexErrMsgTxt("Error setting exposure time");
    } else {
        mexPrintf("Exposure time set to %f ms \n",desiredExpTime);mexEvalString("drawnow;");
    }
    
    if (nlhs == 1) {
        plhs[0] = mxCreateDoubleScalar(desiredExpTime);
    }
    
    return; 
}