// Matlab MEX
//
// Levenberg-Marquardt Least-Squares Fitting of 1D Gaussian
//
// [par, exitflag, residua, numiter, message] = lmfit1DgaussXSAO(par0, X, y, options);
//
// Note that optimized function parameters have limited range such that sigma >= 0, amplitude >= 0, offset >= 0

// This software is released under terms of GNU GPL v3 licence.
// It is provided AS-IS and no warranty is given.

// 2009-2014, Pavel Krizek, Institute of cellular biology and pathology,
// First Faculty of Medicine, Charles University in Prague

#include <math.h>
#include <float.h>
#include "mex.h"
#include "lmmin/lmmin.h"

typedef struct {
	size_t npar;		// number of function parameters to be optimized
	size_t npts;		// number of data points
	size_t dim;		    // data dimension
	double *X;          // matrix of data variables; in Matlab stored as [dim x npts] 
	double *y;          // vector of measured function values     y ~ fun(X,par)
	double (*fun) (double *X, double *par); // fnc definition     y = fun(X,par)
} my_data_type;

__inline double SQR(double x)	
{
	return x*x;
}

// ------------------------------------------------------------------------
// Function to fit
// ------------------------------------------------------------------------
#define DIM 1
#define NPAR 4
double my_fit_function(double *X, double *par)
{
	return par[2] * exp(-0.5 * SQR((X[0] - par[0])/par[1])) + par[3];
}

// Transformation of function parameters to limit their range
void partransf(double *parin, double *parout, size_t npar)
{
	parout[0] = parin[0];       // center stays the same
	parout[1] = SQR(parin[1]);  // sigma >= 0
	parout[2] = SQR(parin[2]);  // amplitude >= 0
	parout[3] = SQR(parin[3]);  // offset >= 0
}

// Inverse transformation of function parameters
void parinvtransf(double *parin, double *parout, size_t npar)
{
	parout[0] = parin[0];
	parout[1] = sqrt(parin[1]);
	parout[2] = sqrt(parin[2]);
	parout[3] = sqrt(parin[3]);
}

// ------------------------------------------------------------------------
// Compute residua for all data points
// ------------------------------------------------------------------------
void my_evaluate(double *par, int npts, double *fvec, void *data, int *info)
{
    my_data_type *mydata = (my_data_type *) data;
	double	*y = mydata->y, *X = mydata->X;
	int		i;
	double p[NPAR];

	// transform function parameters to limit their range
	partransf(par, p, mydata->npar);

	// compute the difference " F = y - fun(X, par) " for all data points
	for (i = 0; i < npts; i++, X += mydata->dim)
		*(fvec++) = *(y++) - mydata->fun(X, p);

	*info = *info;		// to prevent a 'unused variable' warning
}

// ------------------------------------------------------------------------
// Compute sum of residual errors
// ------------------------------------------------------------------------
double meanerror(double *par, int npts, void *data)
{
	double *fvec, *tmp, sum = 0;
	int i;

	if ((fvec = (double *) mxMalloc(npts*sizeof(double))) == NULL)
		mexErrMsgTxt("Not enough memory.\n");

	my_evaluate(par, npts, fvec, data, &i);

	for(i = 0, tmp = fvec; i < npts; i++)
		sum += SQR(*tmp++);
	
	mxFree(fvec);
	
	return sum / (double) npts;
}

// ------------------------------------------------------------------------
// Control parameters
// ------------------------------------------------------------------------

void init_control_userdef(lm_control_type * control, const mxArray *options)
{
	mxArray *ptr;

	if ((ptr = mxGetField(options, 0, "maxcall")) != NULL)
		control->maxcall = (int) mxGetScalar(ptr);

	if ((ptr = mxGetField(options, 0, "epsilon")) != NULL)
		control->epsilon = mxGetScalar(ptr);

	if ((ptr = mxGetField(options, 0, "stepbound")) != NULL)
		control->stepbound = mxGetScalar(ptr);

	if ((ptr = mxGetField(options, 0, "ftol")) != NULL)
		control->ftol = mxGetScalar(ptr);

	if ((ptr = mxGetField(options, 0, "xtol")) != NULL)
		control->xtol = mxGetScalar(ptr);

	if ((ptr = mxGetField(options, 0, "gtol")) != NULL)
		control->gtol = mxGetScalar(ptr);
}

// ------------------------------------------------------------------------
// MAIN 
// ------------------------------------------------------------------------
void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{ 
    const mxArray		*mxpar0, *mxX, *mxy, *mxoptions;
	lm_control_type		control;
    my_data_type		data;
    double				*par;

	// test number of input arguments
	if (nrhs < 3) {
		mexPrintf("\nLevenberg-Marquardt Least Squares Fitting of 1D Gaussian\n\n");
		mexPrintf(" Usage:\n");
		mexPrintf("  [par, meanerr, exitflag, numiter, message] = lmfit1DgaussXSAO(par0, X, y, options);\n\n");
		mexPrintf(" In:\n");
		mexPrintf("   par0     ... [1 x npar]      initial function parameters [mean, sigma, amplitude, offset]\n");
		mexPrintf("   X        ... [dim x npts]    matrix of data variables\n");
		mexPrintf("   y        ... [1 x npts]      vector of measured function values y ~ fun(X,par) \n");
		mexPrintf("   options  ... struct with fileds: maxcall / epsilon / stepbound / ftol / xtol / gtol\n\n");
		mexPrintf(" Out:\n");
		mexPrintf("   par      ... [1 x npar]      optimized parameters [mean, sigma, amplitude, offset]\n");
		mexPrintf("   meanerr  ...                 mean error: sum((y-fun(X,par)).^2)/npts\n");
		mexPrintf("   exitflag ...                 status\n");
		mexPrintf("   numiter  ...                 number of iterations\n");
		mexPrintf("   message  ...                 string with status message\n\n");
		mexPrintf(" Note that following parameters have limited range: sigma >= 0, amplitude >= 0, offset >= 0\n\n");
		return;
	}

	// initialize I/O parameters
	mxpar0 = prhs[0];
	mxX  = prhs[1];
	mxy = prhs[2];
	par = mxGetPr(plhs[0] = mxDuplicateArray(mxpar0));
	
	// initialize input data
    data.fun = my_fit_function;
		
	// get initial function parameters
	if (mxIsEmpty(mxpar0) || !mxIsDouble(mxpar0))
		mexErrMsgTxt("Initial function parameters has to be stored in double vector.\n");
	if ((data.npar = mxGetN(mxpar0)) != NPAR)
		mexErrMsgTxt("Wrong number of function parameters.\n");
	// inverse transform of initial function parameters
	parinvtransf(par,par,data.npar);

	// get data variables   X
	if (mxIsEmpty(mxX) || !mxIsDouble(mxX))
		mexErrMsgTxt("Variables must be stored in double matrix.\n");
	if ((data.dim = mxGetM(mxX)) != DIM)
		mexErrMsgTxt("Wrong data dimension.\n");
	data.npts = mxGetN(mxX);
	data.X = mxGetPr(mxX);

	// get measured function values     y ~ fun(X,par)
	if (mxIsEmpty(mxy) || !mxIsDouble(mxy))
		mexErrMsgTxt("Function values must be stored in double vector.\n");
	if (data.npts != mxGetN(mxy))
		mexErrMsgTxt("Input data are not consistent.\n");
	data.y = mxGetPr(mxy);

	// set fitting options
	lm_initialize_control(&control);
	if ((nrhs > 3) && !mxIsEmpty(mxoptions = prhs[3]) && mxIsStruct(mxoptions))
		init_control_userdef(&control, mxoptions);
	
    // do the fitting
	lm_minimize( data.npts, data.npar, par, my_evaluate, NULL, &data, &control );

	// residual error 
	if (nlhs > 1)
		plhs[1] = mxCreateDoubleScalar(meanerror(par, data.npts, &data));

	// exit flag
	if (nlhs > 2)
		plhs[2] = mxCreateDoubleScalar(control.info);

	// # iterations
	if (nlhs > 3)
		plhs[3] = mxCreateDoubleScalar(control.nfev);

	// message
	if (nlhs > 4)
		plhs[4] = mxCreateString(lm_infmsg[control.info]);

	// get function parameters - use transformation again
	partransf(par, par, data.npar);
}
