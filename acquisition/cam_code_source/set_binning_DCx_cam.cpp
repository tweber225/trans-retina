#include <new>
using namespace std;
#include "mex.h"
#include "uc480.h"

// in MATLAB calling this should look like:
// set_binning_DCx_cam(hCam, desiredBinSize);

// Before calling this function, need to check whether binSize is valid!
// desiredBinSize = 1 (1x1 binning, i.e. binning disabled)
// desiredBinSize = 2 (2x2 binning)

// MEX FUNCTION ENTRY
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{
    // Make sure we have enough inputs
    if (nrhs != 2)
        mexErrMsgTxt("Set binning function is missing arguments!");
    
    // Declare some variables
    int desiredBinSize;
        
    // Get camera handle
    HCAM hCam = *(HCAM *)mxGetPr(prhs[0]);
       
    // Gather desired bin setting
    desiredBinSize = (int)mxGetScalar(prhs[1]);
    
    // Set bin size
    if (desiredBinSize == 1) {
        if (is_SetBinning(hCam, IS_BINNING_DISABLE) != IS_SUCCESS) {
            mexErrMsgTxt("Error disabling binning");
        } else {
            mexPrintf("Binning disabled \n");
        }
    } else if (desiredBinSize == 2) {
        if (is_SetBinning(hCam, IS_BINNING_2X_VERTICAL | IS_BINNING_2X_HORIZONTAL) != IS_SUCCESS) {
            mexErrMsgTxt("Error setting 2x2 binning!");
        } else {
            mexPrintf("Binning is set to 2x2 \n");
        }
    } else {
        mexErrMsgTxt("Attempt to set invalid bin size");
    }
    mexEvalString("drawnow;");
    
    return;
}
        
        