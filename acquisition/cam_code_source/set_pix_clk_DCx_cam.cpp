#include <new>
using namespace std;
#include "mex.h"
#include "uc480.h"

// in MATLAB calling this should look like:
// set_pix_clk_DCx_cam(hCam, newPixClk);

// Before calling this function, need to check whether newPixClk is valid!

// MEX FUNCTION ENTRY
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{
    // Make sure we have enough inputs
    if (nrhs != 2)
        mexErrMsgTxt("Set pixel clock function is missing arguments!");
    
    // Declare some variables
    UINT desiredPixClk;
        
    // Get camera handle
    HCAM hCam = *(HCAM *)mxGetPr(prhs[0]);
       
    // Gather desired pixel clock value from argument list
    desiredPixClk = (UINT)mxGetScalar(prhs[1]);
    
    // Set pixel clock on camera
    INT nRet = is_PixelClock(hCam, IS_PIXELCLOCK_CMD_SET, (void*)&desiredPixClk, sizeof(desiredPixClk));
    if (nRet != IS_SUCCESS) {
        mexErrMsgTxt("Error setting pixel clock!");
    } else {
        mexPrintf("Pixel clock set to %d MHz \n", desiredPixClk);
    }
    
    if (nlhs == 1) {
        plhs[0] = mxCreateDoubleScalar(desiredPixClk);
    }
        
    return;
}
        
        