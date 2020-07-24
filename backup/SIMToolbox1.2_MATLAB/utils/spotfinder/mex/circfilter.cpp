/*
    Filter [x,y] points so they are not closer than a minimum distance

    valid = circfilter([u,v], mindist);
*/


#include "mex.h"

typedef double Pix;

inline Pix SQR(Pix x)
{
	return x*x;
}


void printhelp(void) {
	mexPrintf("\nFilter points such that they are not closer than a minimum distance\n\n");
	mexPrintf(" Usage:\n");
	mexPrintf("  valid = circfilter([x,y], mindist)\n");
	mexPrintf(" In:\n");
	mexPrintf("   [x,y]        ... [npts x 2]   single matrix with coordinates\n");
	mexPrintf("   thr          ... scalar       minimal threshold distance\n");
	mexPrintf(" Out:\n");
	mexPrintf("   valid        ... [npts x 1]   logical indices of valid points\n\n");
}

void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	const mxArray *mxdata, *mxthr;
	Pix *x, *y, dst2;
	size_t i,j, numpts;
	mxLogical *valid;

	// check input arguments
	if (nrhs != 2 || nlhs > 1)
	{
		printhelp();
		return;
	}

	mxdata = prhs[0];
	mxthr = prhs[1];
	
	if (mxIsEmpty(mxdata) || !mxIsDouble(mxdata) || (mxGetNumberOfDimensions(mxdata) != 2) || (mxGetN(mxdata) != 2))
		mexErrMsgTxt("First input argument must be a double matrix [npts x 2].");

	if (mxIsEmpty(mxthr) || !mxIsNumeric(mxthr) || (mxGetNumberOfElements(mxthr) != 1))
		mexErrMsgTxt("Minimal distance must be a scalar.");

	// read values
	numpts = mxGetM(mxdata);
	x = (Pix *) mxGetData(mxdata);
	y = x + numpts;	
	dst2 = SQR((Pix) mxGetScalar(mxthr));

	// allocate output values
	valid = mxGetLogicals(plhs[0] = mxCreateLogicalMatrix(numpts, 1));
	for(i = 0; i < numpts; i++)
		valid[i] = true;

	// check distances
	for(i = 0; i < numpts-1; i++)
	{
		if (!valid[i])
			continue;

		for(j=i+1;j<numpts;j++)
		{
			if (!valid[j])
				continue;

			if ((SQR(x[i]-x[j]) + SQR(y[i]-y[j])) < dst2)
				valid[j] = false;
		}
	}
}
