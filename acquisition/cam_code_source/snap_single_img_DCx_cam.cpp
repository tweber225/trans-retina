using namespace std;
#include "mex.h"
#include "uc480.h"

// in MATLAB calling this should look like:
// snap_single_img_DCx_cam(hCam);


// MEX FUNCTION ENTRY
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{
    // Make sure we have enough inputs
    if (nrhs != 1)
        mexErrMsgTxt("Snap image function is missing arguments!");
    
    // Get camera handle
    HCAM hCam = *(HCAM *)mxGetPr(prhs[0]);
       
    if (is_FreezeVideo(hCam, IS_WAIT) != IS_SUCCESS) {
        mexErrMsgTxt("Failed to snap frame!");
    }
    mexPrintf("Frame grabbed \n");mexEvalString("drawnow;");
    
    return;
}
        
        