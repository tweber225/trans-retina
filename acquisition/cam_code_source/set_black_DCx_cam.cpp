#include <new>
using namespace std;
#include "mex.h"
#include "uc480.h"

// in MATLAB calling this should look like:
// setBlackLevel = set_black_DCx_cam(hCam, newBlackLevel);

// Before calling this function, need to check whether desiredBlackLevel is valid (between 0 and 255)!
// Function should return the actual set black level

// MEX FUNCTION ENTRY
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{
    // Make sure we have enough inputs
    if (nrhs != 2)
        mexErrMsgTxt("Set black level function is missing arguments!");
    
    // Declare some variables
    INT desiredBlackLevel;
    
    // Get camera handle
    HCAM hCam = *(HCAM *)mxGetPr(prhs[0]);
    
    // Get desired black level from input arguments
    desiredBlackLevel = (INT)mxGetScalar(prhs[1]);
        
    // Set black level time
    INT nRet = is_Blacklevel(hCam, IS_BLACKLEVEL_CMD_SET_OFFSET, (void*)&desiredBlackLevel, sizeof(desiredBlackLevel));
    if (nRet != IS_SUCCESS) {
        mexErrMsgTxt("Error setting black level");
    } else {
        mexPrintf("Black level set to %d \n",desiredBlackLevel);mexEvalString("drawnow;");
    }
    
    if (nlhs == 1) {
        plhs[0] = mxCreateDoubleScalar(desiredBlackLevel);
    }
    
    return; 
}