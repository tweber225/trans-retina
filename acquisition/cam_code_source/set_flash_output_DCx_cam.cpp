#include <new>
using namespace std;
#include "mex.h"
#include "uc480.h"

// in MATLAB calling this should look like:
// [flashDelay, flashDuration] = set_flash_output_DCx_cam(hCam, flashMode, exposureTime);

// flashMode indicates which flash output mode to use. Need to specify two output arguments to contain the actual set flash delay and duration.
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
    double currentExposureTime, actualFlashDelay, actualFlashDuration;
    UINT flashModeCode;
    IO_FLASH_PARAMS flashParams;
    IO_GPIO_CONFIGURATION GPIOConfig;
        
    // Get camera handle
    HCAM hCam = *(HCAM *)mxGetPr(prhs[0]);
       
    // Gather desired flash output mode
    flashMode = (int)mxGetScalar(prhs[1]);
    
    // Gather the current exposure time
    currentExposureTime = (double)mxGetScalar(prhs[2]);
    
    // Set the flash parameters (delay always is 0, and duration is exposure time (both set it microseconds for this command)
    flashParams.s32Delay = 0;
    flashParams.u32Duration = (UINT)(currentExposureTime*1000);
    
    // Set the GPIO Configurations (GPIO #1 is synced to flash)
    GPIOConfig.u32Gpio = IO_GPIO_1;
    GPIOConfig.u32Configuration = IS_GPIO_FLASH;
            
    // Set flash
    if (flashMode == 0) {
        //set up the IS_IO_CMD_FLASH_SET_MODE to IO_FLASH_MODE_FREERUN_HI_ACTIVE
        flashModeCode = IO_FLASH_MODE_TRIGGER_HI_ACTIVE;
        if (is_IO(hCam, IS_IO_CMD_FLASH_SET_MODE, (void*)&flashModeCode, sizeof(flashModeCode)) != IS_SUCCESS)
            mexErrMsgTxt("Could not set flash mode");
        // set correct flash parameters (delay and duration)
        if (is_IO(hCam, IS_IO_CMD_FLASH_SET_PARAMS, (void*)&flashParams, sizeof(flashParams)) != IS_SUCCESS)
            mexErrMsgTxt("Could not set flash parameters.");
        actualFlashDelay = (double)flashParams.s32Delay;
        actualFlashDelay = actualFlashDelay/1000;
        actualFlashDuration = (double)flashParams.u32Duration;
        actualFlashDuration = actualFlashDuration/1000;
        //set the GPIO 1 to output flash signals
        if (is_IO(hCam, IS_IO_CMD_GPIOS_SET_CONFIGURATION, (void*)&GPIOConfig, sizeof(GPIOConfig)) != IS_SUCCESS)
            mexErrMsgTxt("Could not configure flash output on GPIO 1");
        mexPrintf("Flash configured to output on GPIO 1 \n");
    }
    mexEvalString("drawnow;");
    
    // Output the actual set flash delay and duration (since they might vary slightly from set values)
    if (nlhs == 2) {
        plhs[0] = mxCreateDoubleScalar(actualFlashDelay);
        plhs[1] = mxCreateDoubleScalar(actualFlashDuration);
    }
    
    return;
}
        
        