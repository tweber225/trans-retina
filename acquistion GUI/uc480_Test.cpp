#include <new>
using namespace std;

// Required to interfacd with the Matlab matrix library
#include "mex.h"

// Required to interface with the uEye cameras
#include "uc480.h"

// Just to make the output a little prettier
#define SEPARATOR "============================================================"

// Using a fixed 8-bit monochrome camera for simplicity
#define BITDEPTH 8

/*******************************************************************************
// Error function that exits camera before displaying error
 ******************************************************************************/
void Error(const char *errormsg, HIDS hCam=0)
{
 if (hCam)
  is_ExitCamera(hCam);
 mexErrMsgTxt(errormsg);
} 


/*******************************************************************************
// Mex entry function
 ******************************************************************************/
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
 // Define variables used later
 int IMAGES = 10, DimSz[3], count;
 char *Img, *ImgOut;      // Pointers to image locations
 INT ncam, NumberOfCameras, ImgID;  // INT defined in uEye.h
 UEYE_CAMERA_LIST *CameraList;   // List of connected cameras
 HIDS hCam = 0;       // Handle to camera
 SENSORINFO Sensor;
 
 
 /***************************************************************************
  * Get connected camera information
  *
  * Cycle through all connected cameras and generate a list of the camera 
  * properites
  **************************************************************************/
 
 // Determine number of connected cameras
 is_GetNumberOfCameras(&NumberOfCameras);
 
 if (!NumberOfCameras)
  Error("No cameras found!");
 
 // Allocate memory to store camera information
 CameraList = (UEYE_CAMERA_LIST*) new (nothrow) BYTE 
   [sizeof(DWORD) + NumberOfCameras * sizeof(UEYE_CAMERA_INFO)];
 
 // Get camera information
 is_GetCameraList(CameraList);
 
 // Output camera information
 mexPrintf("\n\nNumber of connected cameras: %d\n%s\n", 
   NumberOfCameras, SEPARATOR);
 mexPrintf("%-6s%-6s%-6s%-6s%-6s%-12s%-12s%-6s\n%s\n",
   "#", "CamID", "DevID", "Sens", "On", "Serial", "Model", 
   "Status", SEPARATOR);
 for (ncam=0; ncam<NumberOfCameras; ncam++)
  mexPrintf("%-6d%-6d%-6d%-6d%-6d%-12s%-12s%-6d\n",
    ncam, 
    CameraList->uci[ncam].dwCameraID,
    CameraList->uci[ncam].dwDeviceID,
    CameraList->uci[ncam].dwSensorID,
    CameraList->uci[ncam].dwInUse,
    CameraList->uci[ncam].SerNo,
    CameraList->uci[ncam].Model,
    CameraList->uci[ncam].dwStatus);
 mexPrintf("%s\n\n", SEPARATOR);

 // Deallocate camera list memory
 delete [] CameraList;
  
 
 /***************************************************************************
  * Capture from a single camera
  *  Assumes monochrome camera & uses DIB mode
  **************************************************************************/
 
 // Initialise camera
 mexPrintf("Initializing first available camera ...\n");
 if (is_InitCamera(&hCam, NULL) != IS_SUCCESS)
  Error("Could not initialize camera");
 
 // Set to monochrome
 mexPrintf("Setting colormode to monochrome ...\n");
 if (is_SetColorMode(hCam, IS_CM_MONO8) != IS_SUCCESS)
  Error("Could not set camera to monochrome", hCam);

 // Set to bitmap mode
 mexPrintf("Setting display mode to bitmap (DIB) ...\n");
 if (is_SetDisplayMode(hCam, IS_SET_DM_DIB) != IS_SUCCESS)
  Error("Could not set display mode", hCam);
 
 // Set trigger mode to software
 is_SetExternalTrigger(hCam, IS_SET_TRIGGER_SOFTWARE);

 // Get camera information
 is_GetSensorInfo(hCam, &Sensor);
  
 // Display camera information
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

 // Get number of images to acquire
 if (nrhs && mxIsScalar(prhs[0]) && mxGetScalar(prhs[0])>=0)
  IMAGES = (int)mxGetScalar(prhs[0]);
   
 // Set up output array
 if (nlhs) {
  DimSz[0] = Sensor.nMaxHeight;
  DimSz[1] = Sensor.nMaxWidth;
  DimSz[2] = IMAGES;
  plhs[0] = mxCreateNumericArray(3, (const size_t *)DimSz, mxUINT8_CLASS, mxREAL);
  ImgOut = (char *) mxGetData(plhs[0]);
 }
 
 // Allocate image memory
 mexPrintf("Allocating memory ...\n");
 if (is_AllocImageMem(hCam, Sensor.nMaxWidth, Sensor.nMaxHeight, BITDEPTH, 
   &Img, &ImgID) != IS_SUCCESS)
  Error("Could not allocate memory!", hCam); 
 
 // Set current image
 mexPrintf("Setting current image ...\n");
 if (is_SetImageMem(hCam, Img, ImgID) != IS_SUCCESS)
  Error("Could not set current image memory!", hCam); 
 
 // Capture images
 mexPrintf("Capture %d images ...\n", IMAGES);
 for (count=0; count<IMAGES; count++) {
  mexPrintf("\t%d", count+1);
  if (is_FreezeVideo(hCam, IS_WAIT) != IS_SUCCESS)
   Error("Could not capture image", hCam);
  
  if (nlhs) {
   if (is_CopyImageMem(hCam, Img, ImgID, ImgOut) != IS_SUCCESS)
    Error("Could not copy image", hCam);
   ImgOut += Sensor.nMaxWidth*Sensor.nMaxHeight;
  }
 }

 // Deallocate memory
 mexPrintf("\nDeallocating memory ...\n");
 is_FreeImageMem(hCam, Img, ImgID);

 // Release camera
 is_ExitCamera(hCam);
  
 mexPrintf("\n%s\n%35s\n%s\n\n", SEPARATOR, "C O M P L E T E", SEPARATOR);
 
 return;
}