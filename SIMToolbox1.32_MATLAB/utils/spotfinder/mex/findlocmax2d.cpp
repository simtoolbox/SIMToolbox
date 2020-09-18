/*
  idx = findlocmax2d(X, thr, N)

    X    ... [m x n] double matrix
    thr  ... double scalar - threshold (def. -Inf)
    N    ... 4 | 8 connectivity neighbourhood (def. 4)
    idx  ... uint32 list of local maxima indices
   
  26.4.2011 PK - added 8 neighbourhood and threshold
  23.4.2010 PK - local max in 4 neighbourhood
*/

#include "mex.h"
#include "listsingle.h"
#include <float.h>

typedef unsigned long uint32;
typedef ListSingle<uint32> list;

// ---------------------------------------------------------------------------	
void locmax4(double * const data, const int m, const int n, const double thr, list *ll)
{
	int i,j,k;
	double *p = data, *q[4];	

	// init
	p += m + 1;
	q[0] = p-1;
	q[1] = p+1;
	q[2] = p-m;
	q[3] = p+m;

	// find all local maxima in 4 neighbourhood
	for(j = 1; j < n-1; j++) {
		
		// process one colon
		for(i = 1; i < m-1; i++) {

			// find local maxima
			//if ((*p > thr) && (*p >= *q[0]) && (*p >= *q[1]) && (*p >= *q[2]) && (*p >= *q[3]))
			if ((*p > thr) && (*p > *q[0]) && (*p > *q[1]) && (*p > *q[2]) && (*p > *q[3]))
				ll->AddHead(p-data+1); // MATLAB+1

			// next row
			p++;
			for(k=0; k<4; k++)
				q[k]++;
		}
		
		// next colon
		p+=2;
		for(k=0; k<4; k++)
			q[k]+=2;
	}	
}

// ---------------------------------------------------------------------------	
void locmax8(double * const data, const int m, const int n, double thr, list *ll)
{
	int i,j,k;
	double *p = data, *q[8];	

	// init
	p += m + 1;
	q[0] = p-1;
	q[1] = p+1;
	q[2] = p-m;
	q[3] = p+m;	
	q[4] = p-m-1;
	q[5] = p-m+1;
	q[6] = p+m-1;
	q[7] = p+m+1;

	// find all local maxima in 4 neighbourhood
	for(j = 1; j < n-1; j++) {
		
		// process one colon
		for(i = 1; i < m-1; i++) {

			// find local maxima
			//if ((*p > thr) && (*p >= *q[0]) && (*p >= *q[1]) && (*p >= *q[2]) && (*p >= *q[3]) && (*p >= *q[4]) && (*p >= *q[5]) && (*p >= *q[6]) && (*p >= *q[7]))
			if ((*p > thr) && (*p > *q[0]) && (*p > *q[1]) && (*p > *q[2]) && (*p > *q[3]) && (*p > *q[4]) && (*p > *q[5]) && (*p > *q[6]) && (*p > *q[7]))
				ll->AddHead(p-data+1); // MATLAB+1

			// next row
			p++;
			for(k=0; k<8; k++)
				q[k]++;
		}
		
		// next colon
		p+=2;
		for(k=0; k<8; k++)
			q[k]+=2;
	}	
}

// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------

void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	int m,n;
	int neighbour = 4;
	double thr = -FLT_MAX;
	list ll;
	uint32 *out;
	

	// input arguments
	if ((nrhs < 1) || !mxIsDouble(prhs[0]) || (mxGetNumberOfDimensions(prhs[0]) != 2))
		mexErrMsgTxt("First input argument must be double matrix.");

	if ((nrhs > 1) && !mxIsEmpty(prhs[1])) 
		if (mxIsDouble(prhs[1]) && (mxGetNumberOfElements(prhs[1]) == 1))
			thr = (double) mxGetScalar(prhs[1]);
		else
			mexErrMsgTxt("Threshold must be double scalar.");

	if (nrhs > 2)
		neighbour = (int) mxGetScalar(prhs[2]);


	m = mxGetM(prhs[0]);
	n = mxGetN(prhs[0]);

	// find local maxima
	switch (neighbour)
	{
		case 4:
			locmax4((double *)mxGetData(prhs[0]), m, n, thr, &ll);
			break;
		case 8:
			locmax8((double *)mxGetData(prhs[0]), m, n, thr, &ll);
			break;
		default:
			mexErrMsgTxt("Unknown neighbourhood option.");
	}
			
	// save output
	plhs[0] = mxCreateNumericMatrix(ll.Num(), 1, mxUINT32_CLASS,mxREAL);
	out = (uint32*) mxGetData(plhs[0]);
	while (!ll.IsEmpty())
		*(out++) = ll.DeleteHead();
}


