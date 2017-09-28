#include <new>
using namespace std;
#include "mex.h"
#include "uc480.h"

#define SEPARATOR "============================================================"


// in MATLAB calling this should look like:
// [camHandle, modelNum, prevFrameStruct, capFrameStruct] = open_init_DCx_cam();


// CUSTOM ERROR FUNCTION TO EXIT CAMERA BEFORE CLOSING THE PROGRAM (SO THE CAMERA DOESN'T GET TIED UP)
void ExitError(const char *errormsg, HCAM hCam=0)
{
    if (hCam)
        is_ExitCamera(hCam);
    mexErrMsgTxt(errormsg);
}


// MEX FUNCTION ENTRY
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{
    // Define variables used later
    int bitDepth;
    INT numCameras, camIdx, pixelBitDepthFormat;
    UC480_CAMERA_LIST *cameraList;   // List of connected cameras
    HCAM hCam = 0;       // Handle to camera, choosing first available, errors outs if more than 1 connected
    SENSORINFO Sensor;

    
    mexPrintf("Checking for connected DCx cameras ...\n");mexEvalString("drawnow;");

    // Determine number of connected cameras, if not 1, then throw errors
    is_GetNumberOfCameras(&numCameras);

    if (!numCameras)
        ExitError("Check that the camera is connected!");

    // Allocate memory to store camera information
    cameraList = (UC480_CAMERA_LIST*) new (nothrow) BYTE [sizeof(DWORD) + numCameras * sizeof(UC480_CAMERA_INFO)];
    cameraList->dwCount = numCameras;

    // Get camera information
    is_GetCameraList(cameraList);

    // Output camera information
    mexPrintf("\nNumber of connected cameras: %d\n%s\n", numCameras, SEPARATOR);mexEvalString("drawnow;");
    mexPrintf("%-6s%-6s%-6s%-6s%-6s%-12s%-12s%-6s\n%s\n","#", "CamID", "DevID", "Sens", "On", "Serial", "Model", "Status", SEPARATOR);mexEvalString("drawnow;");
    for (camIdx=0; camIdx<numCameras; camIdx++)
        mexPrintf("%-6d%-6d%-6d%-6d%-6d%-12s%-12s%-6d\n",
            camIdx+1, 
            cameraList->uci[camIdx].dwCameraID,
            cameraList->uci[camIdx].dwDeviceID,
            cameraList->uci[camIdx].dwSensorID,
            cameraList->uci[camIdx].dwInUse,
            cameraList->uci[camIdx].SerNo,
            cameraList->uci[camIdx].Model,
            cameraList->uci[camIdx].dwStatus);
    mexPrintf("%s\n\n", SEPARATOR);mexEvalString("drawnow;");
    
    // Deallocate camera list memory
    delete [] cameraList;
    
    if (numCameras>1)
        ExitError("Too many cameras connected, disconnect leaving just one for imaging");
    
    // Get bit depth
    if (nrhs && mxIsScalar(prhs[0]) && mxGetScalar(prhs[0])>=8)
        bitDepth = (INT)mxGetScalar(prhs[0]);
    if (bitDepth<8 || bitDepth>16)
        ExitError("Please enter a valid monochrome bit depth between 8 and 16");
    if (bitDepth == 8) {
        pixelBitDepthFormat = IS_CM_MONO8;
    } else if (bitDepth>8 && bitDepth<=12) {
        pixelBitDepthFormat = IS_CM_MONO12;
        bitDepth = 12;
    } else if (bitDepth>12 && bitDepth<=16) {
        pixelBitDepthFormat = IS_CM_MONO16;
        bitDepth = 16;
    }
    
    // Initialize camera; set to monochrome, 12-bit; set to bitmap mode; set software triggering
    mexPrintf("Initializing camera ...\n");mexEvalString("drawnow;");
    if (is_InitCamera(&hCam, NULL) != IS_SUCCESS)
        ExitError("Could not initialize camera");
    mexPrintf("Setting colormode to monochrome, %d-bit ...\n",bitDepth);mexEvalString("drawnow;");
    if (is_SetColorMode(hCam, pixelBitDepthFormat) != IS_SUCCESS)
        ExitError("Could not set camera bit depth", hCam);
    mexPrintf("Setting display mode to bitmap (DIB) ...\n");mexEvalString("drawnow;");
    if (is_SetDisplayMode(hCam, IS_SET_DM_DIB) != IS_SUCCESS)
        ExitError("Could not set display mode", hCam);
    mexPrintf("Setting trigger to software ...\n");mexEvalString("drawnow;");
    if (is_SetExternalTrigger(hCam, IS_SET_TRIGGER_SOFTWARE) != IS_SUCCESS)
        ExitError("Could not set software trigger", hCam);
    
    // Get camera information and display it
    is_GetSensorInfo(hCam, &Sensor);
    mexPrintf("\n%s\nCamera information\n%s\n%15s: %d\n%15s: %s\n%15s: %d\n%15s: %d\n"
        "%15s: %d\n%15s: %d\n%15s: %f\n%s\n\n",
        SEPARATOR, SEPARATOR,
        "Camera #", hCam,
        "Sensor Name", Sensor.strSensorName,
        "Monochrome", (Sensor.nColorMode==1),
        "Max Width", Sensor.nMaxWidth,
        "Max Height", Sensor.nMaxHeight,
        "Global Shutter", (INT) Sensor.bGlobShutter,
        "Pixel Size [um]", .01*Sensor.wPixelSize,
        SEPARATOR);
    mexEvalString("drawnow;");
        
    // Release camera
    is_ExitCamera(hCam);
    mexPrintf("\n%s\n%35s\n%s\n\n", SEPARATOR, "C O M P L E T E", SEPARATOR);mexEvalString("drawnow;");
 
    return;   
}