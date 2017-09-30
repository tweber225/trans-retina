#include <new>
using namespace std;
#include "mex.h"
#include "uc480.h"

// in MATLAB calling this should look like:
// setMasterGain = set_master_gain_DCx_cam(hCam, desiredMasterGain);

// Before calling this function, need to check whether desiredMasterGain is valid!

// MEX FUNCTION ENTRY
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{
    // Make sure we have enough inputs
    if (nrhs != 2)
        mexErrMsgTxt("Set master gain function is missing arguments!");
    
    // Declare some variables
    double desiredMasterGain;
    INT desiredMasterGainTimes100;
        
    // Get camera handle
    HCAM hCam = *(HCAM *)mxGetPr(prhs[0]);
       
    // Gather desired pixel clock value from argument list
    desiredMasterGain = (double)mxGetScalar(prhs[1]);
    desiredMasterGainTimes100 = (INT)(desiredMasterGain*100);

    // Set pixel clock on camera
    INT setMasterGainTimes100 = is_SetHWGainFactor(hCam, IS_SET_MASTER_GAIN_FACTOR, desiredMasterGainTimes100);
    double setMasterGain = setMasterGainTimes100;
    setMasterGain = setMasterGain/100;
    mexPrintf("Master gain set to %f \n", setMasterGain);

    if (nlhs == 1) {
        plhs[0] = mxCreateDoubleScalar(setMasterGain);
    }
        
    return;
}
        
        