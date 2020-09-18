/*

function [boxmu,boxstd] = boxmustd(im,boxsize,boxstep)

20.10.2010, PK
*/

#include "mex.h"
#include <math.h>

inline double SQR(double x)
{
	return x*x;
}

void boxmustd(double * const pim, const int m, const int n, const int size, const int step, double *pmu, double *pstd)
{
	int r, c, i, j, rr, cc, npts = size*size;
	double mu, std, norm = SQR((double)size/(double)step);
	double *p;

	for(cc = 0; cc < size; cc += step)
	{
		for(rr = 0; rr < size; rr += step)
		{
			for(c = cc; c < n-size; c += size)
			{
				for(r = rr; r < m-size; r += size)
				{
					// compute mean
					p = pim + r + c*m;
					for(i = 0, mu = 0; i < size; i++, p += m-size)
						for(j = 0; j < size; j++, p++)
							mu += *p;
					mu /= npts;

					// compute std
					p = pim + r + c*m;
					for(i = 0, std = 0; i < size; i++, p += m-size)
						for(j = 0; j < size; j++, p++)
							std += SQR(*p - mu);
					std = sqrt(std/(npts-1));

					// write mean
					mu /= norm;
					p = pmu + r + c*m;
					for(i = 0; i < size; i++, p += m-size)
						for(j = 0; j < size; j++, p++)
							*p += mu;

					// write std
					std /= norm;
					p = pstd + r + c*m;
					for(i = 0; i < size; i++, p += m-size)
						for(j = 0; j < size; j++, p++)
							*p += std;

				}
			}
		}
	}
}

/* ------------------------------------------------------------------------ */
// M A I N
/* ------------------------------------------------------------------------ */

void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{	
	double *pim, *pmu = NULL, *pstd = NULL;
	int m, n;
	int boxsize = 8, boxstep = 2;
	
	
	// check number of I/O arguments
	if ((nrhs < 1) || (nrhs > 3))
		mexErrMsgTxt("Wrong number of input arguments.");
	if ((nlhs < 1) )//|| (nlhs > 3))
		mexErrMsgTxt("Wrong number of output arguments.");

	// input image
	if ( mxIsEmpty(prhs[0]) || !mxIsDouble(prhs[0]) )
		mexErrMsgTxt("Image must be double matrix.");

	pim = mxGetPr(prhs[0]);
	m = (int) mxGetM(prhs[0]);
	n = (int) mxGetN(prhs[0]);

	// get boxsize
	if (nrhs > 1) {
		if (!mxIsNumeric(prhs[1]) || (mxGetNumberOfElements(prhs[1]) != 1))
			mexErrMsgTxt("boxsize must be numeric scalar.");
		else
			boxsize = (int) mxGetScalar(prhs[1]);
	}

	// get boxstep
	if (nrhs > 2) {
		if (!mxIsNumeric(prhs[2]) || (mxGetNumberOfElements(prhs[2]) != 1))
			mexErrMsgTxt("boxsize must be numeric scalar.");
		else
			boxstep = (int) mxGetScalar(prhs[2]);
	}

	// initialize output
	//if (nlhs > 0) {
		plhs[0] = mxCreateNumericMatrix(m, n, mxDOUBLE_CLASS, mxREAL);
		pmu = mxGetPr(plhs[0]);
	//}

	//if (nlhs > 1) {
		plhs[1] = mxCreateNumericMatrix(m, n, mxDOUBLE_CLASS, mxREAL);
		pstd = mxGetPr(plhs[1]);
	//}


	boxmustd(pim, m, n, boxsize, boxstep, pmu, pstd);
}