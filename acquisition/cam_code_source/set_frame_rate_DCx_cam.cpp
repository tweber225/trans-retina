#include <new>
using namespace std;
#include "mex.h"
#include "uc480.h"

// in MATLAB calling this should look like:
// actualFrameRate = set_frame_rate_DCx_cam(hCam, newFrameRate);

// Before calling this function, need to check whether desiredFrameRate is valid!
// Function should return the actual set frame rate

// MEX FUNCTION ENTRY
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{
    // Make sure we have enough inputs
    if (nrhs != 2)
        mexErrMsgTxt("Set frame rate function is missing arguments!");
    
    // Declare some variables
    double desiredFrameRate, actualFrameRate;
            
    // Get camera handle
    HCAM hCam = *(HCAM *)mxGetPr(prhs[0]);
       
    // Gather desired frame rate value from argument list
    desiredFrameRate = (double)mxGetScalar(prhs[1]);
    
    // Set pixel clock on camera
    INT nRet = is_SetFrameRate(hCam, desiredFrameRate, &actualFrameRate);
    if (nRet != IS_SUCCESS) {
        mexErrMsgTxt("Error setting pixel clock!");
    } else {
        mexPrintf("Frame rate set to %f fps. \n", actualFrameRate);
    }
    
    if (nlhs == 1) {
        plhs[0] = mxCreateDoubleScalar(actualFrameRate);
    }
        
    return;
}
        
        