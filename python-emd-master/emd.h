#ifndef _EMD_H
#define _EMD_H
/*
    emd.h

    Last update: 3/24/98

    An implementation of the Earth Movers Distance.
    Based of the solution for the Transportation problem as described in
    "Introduction to Mathematical Programming" by F. S. Hillier and 
    G. J. Lieberman, McGraw-Hill, 1990.

    Copyright (C) 1998 Yossi Rubner
    Computer Science Department, Stanford University
    E-Mail: rubner@cs.stanford.edu   URL: http://vision.stanford.edu/~rubner
*/


/* DEFINITIONS */
#define MAX_SIG_SIZE   100
#define MAX_ITERATIONS 500
#define INFINITY       1e20
#define EPSILON        1e-6

/*****************************************************************************/
/* feature_t SHOULD BE MODIFIED BY THE USER TO REFLECT THE FEATURE TYPE      */

// The implementation treats features as opaque objects.  They only get used
// as arguments to the ground distance callback when building the distance
// matrix.  Thus, with a Python distance callback, any Python object is fine.

#include "Python.h";
typedef PyObject* feature_t;
/*****************************************************************************/


typedef struct
{
  int n;                /* Number of features in the signature */
  feature_t *Features;  /* Pointer to the features vector */
  float *Weights;       /* Pointer to the weights of the features */
} signature_t;


typedef struct
{
  int from;             /* Feature number in signature 1 */
  int to;               /* Feature number in signature 2 */
  float amount;         /* Amount of flow from "from" to "to" */
} flow_t;



float emd(signature_t *Signature1, signature_t *Signature2,
	  float (*func)(feature_t *, feature_t *),
	  flow_t *Flow, int *FlowSize);

#endif
