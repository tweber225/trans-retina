#include <new>
using namespace std;
#include "mex.h"
#include "uc480.h"

// in MATLAB calling this should look like:
// close_DCx_cam(hCam);

// MEX FUNCTION ENTRY
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{
    // Make sure we have a camera handle input
    if (nrhs != 1)
        mexErrMsgTxt("Close camera function is missing camera handle input argument");
    
    // Get camera handle
    HCAM hCam = *(HCAM *)mxGetPr(prhs[0]);

    // Exit camera
    mexPrintf("Closing camera ...\n");mexEvalString("drawnow;");
    if (is_ExitCamera(hCam) != IS_SUCCESS)
        mexErrMsgTxt("Failed to close out camera");
    mexPrintf("%s\n\n", "Camera successfully closed.");mexEvalString("drawnow;");
 
    return; 
}