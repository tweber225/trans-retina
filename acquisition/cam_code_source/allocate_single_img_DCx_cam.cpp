using namespace std;
#include "mex.h"
#include "uc480.h"

// in MATLAB calling this should look like:
// [pImgMem, imgID] = set_binning_DCx_cam(hCam, width, height, bitDepth);

// Before calling this function, need to check whether width, height, and bit depths are valid!


// MEX FUNCTION ENTRY
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{
    // Make sure we have enough inputs
    if ((nrhs != 4) || (nlhs !=2))
        mexErrMsgTxt("Set binning function is missing input or output arguments!");
    
    // Declare some variables
    int width, height, bitDepth;
    char *pImgMem = NULL;
    INT imgID;
    
    
    // Get camera handle
    HCAM hCam = *(HCAM *)mxGetPr(prhs[0]);
       
    // Gather the desired lengths of image dimensions
    height = (int)mxGetScalar(prhs[1]);
    width = (int)mxGetScalar(prhs[2]);
    bitDepth = (int)mxGetScalar(prhs[3]);
    
    // Allocate the memory
    if (is_AllocImageMem(hCam, width, height, bitDepth, &pImgMem, &imgID) != IS_SUCCESS) {
        mexErrMsgTxt("Failed to allocate memory for image!");
    }
    
    // Activate the memory
    if (is_SetImageMem(hCam, pImgMem, imgID) != IS_SUCCESS) {
        mexErrMsgTxt("Failed to activate image memory!");
    }
    mexPrintf("Memory successfully allocated and activated (location: %llu) \n",pImgMem);mexEvalString("drawnow;");
    
    // Output the pointer to image memory location (needs to be at least 64 bits, i.e. long long)
    long long *pImgMemOut = NULL;
    plhs[0] = mxCreateNumericMatrix(1,1,mxINT64_CLASS,mxREAL);
    pImgMemOut = (long long *)mxGetData(plhs[0]);
    *pImgMemOut = (long long)pImgMem;
    
    // Output image ID
    int *imgIDOut;
    plhs[1] = mxCreateNumericMatrix(1,1,mxINT32_CLASS,mxREAL);
    imgIDOut = (int *)mxGetData(plhs[1]);
    *imgIDOut = (int)imgID;
    
    return;
}
        
        