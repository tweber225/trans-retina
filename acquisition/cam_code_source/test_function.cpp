using namespace std;
#include "mex.h"
#include "uc480.h"

// FUNCTION TO TEST MEX
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[] )
{
    // Make sure we have enough inputs
    if (nrhs != 1)
        mexErrMsgTxt("missing arguments!");
    
    long long timbo;
    timbo = *(long long *)mxGetData(prhs[0]);
    mexPrintf("Location: %llu \n",timbo);
    
    char *charPointer = NULL;
    charPointer = (char *)timbo;
    mexPrintf("Location: %llu \n",charPointer);

  
    return;
}
        
        