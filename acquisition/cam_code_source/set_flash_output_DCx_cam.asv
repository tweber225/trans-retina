#include <new>
using namespace std;
#include "mex.h"
#include "uc480.h"

// in MATLAB calling this should look like:
// set_flash_output_DCx_cam(hCam, flashMode);

// flashMode indicates which trigger mode to use. No need for an output argument.
// The codes are:
// flashMode = 0: sets the flash mode to sync with the exposure time (delay =0, duration = exposure time), and to output this  GPIO1


// MEX FUNCTION ENTRY
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{
    // Make sure we have enough inputs
    if (nrhs != 3)
        mexErrMsgTxt("Set flash mode function is missing arguments!");
    
    // Declare some variables
    int flashMode;
        
    // Get camera handle
    HCAM hCam = *(HCAM *)mxGetPr(prhs[0]);
       
    // Gather desired flash output mode
    flashMode = (int)mxGetScalar(prhs[1]);
    
    // Gather the current exposure time
    currentExposureTime = (double)mxGetScalar(prhs[2]);

    // Set flash
    if (flashMode == 0) {
        
        //set up the IS_IO_CMD_FLASH_SET_MODE to IO_FLASH_MODE_FREERUN_HI_ACTIVE
        
        // set correct flash parameters (delay and duration)
        
        //set the GPIO 1 to output flash signals
        if (is_IO(hCam, ) != IS_SUCCESS)
            mexErrMsgTxt("Could not configure flash output on GPIO 1");
        mexPrintf("Flash configured to output on GPIO 1 \n");
    
        
    }
    mexEvalString("drawnow;");        
    return;
}
        
        