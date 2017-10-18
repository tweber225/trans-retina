using namespace std;
#include "mex.h"
#include "uc480.h"

// in MATLAB calling this should look like:
// I = read_single_img_DCx_cam(hCam, pImgMem, imgID);

// Before calling this function, need to check whether imgStruct is valid!


// MEX FUNCTION ENTRY
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{
    // Make sure we have enough inputs
    if (nrhs != 3)
        mexErrMsgTxt("Copy image memory function is missing arguments!");
    
    // Get camera handle
    HCAM hCam = *(HCAM *)mxGetPr(prhs[0]);
       
    // Get image memory pointer and ID
    char *pImgMem = NULL;
    long long pImgMemTemp;
    pImgMemTemp = *(long long *)mxGetData(prhs[1]);
    pImgMem = (char *)pImgMemTemp;
    INT imgID = *(INT *)mxGetData(prhs[2]);
  
    // Copy the memory to MATLAB
    char *pImgDest;
    plhs[0] = mxCreateNumericMatrix(1280,1024,mxUINT16_CLASS, mxREAL);
    pImgDest = (char *) mxGetData(plhs[0]);
    if (is_CopyImageMem(hCam, pImgMem, imgID, pImgDest) != IS_SUCCESS) {
        mexErrMsgTxt("Failed to copy image memory!");
    }
    mexPrintf("Data copied \n");mexEvalString("drawnow;");
    
    return;
}
        
        