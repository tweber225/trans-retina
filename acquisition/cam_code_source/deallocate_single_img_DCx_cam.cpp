using namespace std;
#include "mex.h"
#include "uc480.h"

// in MATLAB calling this should look like:
// deallocate_single_img_DCx_cam(hCam, pImgMem, imgID);

// Before calling this function, need to check whether imgStruct is valid!


// MEX FUNCTION ENTRY
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{
    // Make sure we have enough inputs
    if (nrhs != 3)
        mexErrMsgTxt("Deallocate memory function is missing arguments!");
    
    // Get camera handle
    HCAM hCam = *(HCAM *)mxGetPr(prhs[0]);
       
    // Get image memory pointer and ID
    char *pImgMem = NULL;
    long long pImgMemTemp;
    pImgMemTemp = *(long long *)mxGetData(prhs[1]);
    pImgMem = (char *)pImgMemTemp;
    INT imgID = *(INT *)mxGetData(prhs[2]);
  
    // Deactivate the memory
    if (is_FreeImageMem(hCam, pImgMem, imgID) != IS_SUCCESS) {
        mexErrMsgTxt("Failed to deactivate image memory!");
    }
    mexPrintf("Memory successfully freed (location %d \n",pImgMem);mexEvalString("drawnow;");
    
    return;
}
        
        