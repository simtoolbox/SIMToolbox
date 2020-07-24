/*
   Compute 2D Homography and Radial distortion (3 coeficients)

   [Hi2w,Hw2i,Ri2w,Rw2i] = cal2Destim(ipts, wpts)

   ipts, wpts  [numpts x 2] corresponding points in image and world (gdf)
   Hi2w,Hw2i   [3 x 3]
   Ri2w,Rw2i   [cx, cy, r0, r1, r2]

*/


#include "mex.h"

#include "struct.h"
#include "tools.h"
#include "nummath.h"
#include "image.h"
#include "curve.h"

#include "calibr.h"


#define MinPts 15
#define numRadialCoefs 3  // calibr.cpp - is forced to have 3 coeficients

//extern "C" {

void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	double *ipts, *wpts;
	int numpts;

	// prepare estimators
	RHTransform i2w;
	HRTransform w2i;
	Calibration cal;
	RadialHomoEstimator	estim(numRadialCoefs);
	
	// check input arguments
	if (nrhs == 0) {
		mexPrintf("[Hi2w,Hw2i,Ri2w,Rw2i] = cal2Destim(ipts, wpts)\n"); return;	}
	if (nrhs != 2)
		mexErrMsgTxt("Function takes 2 input arguments.\n");
	if (!mxIsDouble(prhs[0]) || !mxIsDouble(prhs[1]) || (mxGetN(prhs[0]) != 2) || (mxGetN(prhs[1]) != 2))
		mexErrMsgTxt("Input arguments must be double [npts x 2] coordinates.\n");
	if ( (numpts = mxGetM(prhs[0])) != mxGetM(prhs[1]) )
		mexErrMsgTxt("Input coordinates must have the same number of points.\n");
	if ( numpts <= MinPts )
		mexErrMsgTxt("Not enough points.");

	// assign data pointers
	ipts = mxGetPr(prhs[0]);
	wpts = mxGetPr(prhs[1]);

	// 
	// calibr.cpp - forced to have 3 coeficients
	// 
	// get number of rad. coefs. 
	//if (nrhs == 3)
	//	if ((numRadialCoefs = (int) mxGetScalar(prhs[2])) < 1)
	//		mexErrMsgTxt("Num of radial coeficients must be > 0.");


	try
	{	
		// add points
		for(int i = 0; i < numpts; i++, ipts++, wpts++)
			estim.AddPointPair(Point(*ipts,*(ipts+numpts)),Point(*wpts,*(wpts+numpts)));

		// fit transform
		estim.FitTransform(i2w);
		estim.FitInverseTransform(w2i);

		// get transform
		cal.Set(i2w, w2i);
	}
	catch(...)
	{
		mexErrMsgTxt("Cannot fit");
	}

	// return i2w homography
	plhs[0] = mxCreateDoubleMatrix(3,3,mxREAL);
    Matrix<double> homo(mxGetPr(plhs[0]),3,3,3);
	cal.GetHomo(homo);

	// return w2i homography
	plhs[1] = mxCreateDoubleMatrix(3,3,mxREAL);
	Matrix<double> revHomo(mxGetPr(plhs[1]),3,3,3);
	cal.GetRevHomo(revHomo);

	// return i2w radial
	plhs[2] = mxCreateDoubleMatrix(1,numRadialCoefs+2,mxREAL);
	Point center;
	double *data = mxGetPr(plhs[2]);
	cal.GetRadial(center,data+2);
	data[0] = center.x;
	data[1] = center.y;

	// return w2i radial
	plhs[3] = mxCreateDoubleMatrix(1,numRadialCoefs+2,mxREAL);
	data = mxGetPr(plhs[3]);
	cal.GetRevRadial(center,data+2);
	data[0] = center.x;
	data[1] = center.y;
}

//} // extern "C"


