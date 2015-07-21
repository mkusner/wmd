/**
 * SWIG Python interface description for Yossi Rubner's EMD implementation.
 * (Available from http://vision.stanford.edu/~rubner)
 *
 * Copyright (c) 2011 Peter Dinges <pdinges@acm.org>
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * $Id$
 **/

%module emd

%{
// Moved the typedef into emd.h
// typedef PyObject* feature_t;
#include "emd.h"

static PyObject *distance_callback = NULL;

/**
 *  C wrapper for callbacks to the Python ground distance function.
 *
 *  The typemap transforming the ground distance function pointer argument
 *  (of type float (*)(feature_t *, feature_t *); see below) first sets the
 *  global 'distance_callback' variable and then returns a pointer to this
 *  function.  When called, the function invokes the Python callable stored
 *  in 'distance_callback' with the two features, and then converts the
 *  returned Python float, that is, the distance, into a C float.
 **/
float distance_from_callback(feature_t *feature1, feature_t *feature2)
{
    PyObject *result = NULL;
    PyObject *arguments;
    float d = INFINITY;
    
    if (distance_callback != NULL) {
		arguments = Py_BuildValue("(OO)", *feature1, *feature2);
		result = PyObject_CallObject(distance_callback, arguments);
		Py_DECREF(arguments);
		if (result != NULL) {
		    if (PyFloat_Check(result)) {
				d = (float) PyFloat_AsDouble(result);
		    } else {
				PyErr_SetString(PyExc_TypeError, "distance function must return a float");
		    }
		    Py_DECREF(result);
		}
    }

    return d;
}

%}


/**
 * Automatic function argument converter for generating signature_t structure
 * pointers from Python objects.
 *
 * The Python object must be a 2-tuple.  Its first entry is interpreted as
 * the list of features; the second entry is the list of weights.  Both
 * entries must be Python lists of identical length.
 * 
 * Any Python object can be used as features: the EMD implementation treats
 * them as opaque objects and they only serve as arguments to the ground
 * distance function to build the distance matrix.  The weights list, however,
 * must consist of floating point numbers.
 **/
%typemap(in) signature_t * {
    int i,j;

	// Start the tedious type checking (on $input):
	// Is it a tuple?
    if (!PyTuple_Check($input)) {
		PyErr_SetString(PyExc_TypeError,
						"expected a tuple of size two (features,weights)");
		return NULL;
    }
    
    // Does it have length 2?
    Py_ssize_t tuple_size = PyTuple_Size($input);
    if (tuple_size != 2) {
		PyErr_SetString(PyExc_TypeError,
						"expected a tuple of size two (features,weights)");
		return NULL;
    }
    
    // Are the entries lists of the same length?
    PyObject *features = PyTuple_GetItem($input,0);
    PyObject *weights = PyTuple_GetItem($input,1);
    if (!PyList_Check(features)) {
		PyErr_SetString(PyExc_TypeError, "first entry (features) must be a list");
		return NULL;
    }
    if (!PyList_Check(weights)) {
		PyErr_SetString(PyExc_TypeError, "second entry (weights) must be a list");
		return NULL;
    }
    
    Py_ssize_t features_count = PyList_Size(features);
    Py_ssize_t weights_count = PyList_Size(weights);
    if (features_count != weights_count) {
	PyErr_SetString(PyExc_TypeError,
			"tuple entries (features,weights) must have same length");
	return NULL;
    }
    
    // Allocate some memory for constructing the signature_t structure.
    PyObject **features_array = (PyObject **) malloc(features_count * sizeof(PyObject *));
    float *weights_array = (float *) malloc(features_count * sizeof(float));
    
    // Fill the weights and feature arrays.
    for (i = 0; i < weights_count; ++i) {
		PyObject *w = PyList_GetItem(weights, i);
		if (PyFloat_Check(w)) {
		    // FIXME The interface requires downcasting doubles to floats...
		    weights_array[i] = (float) PyFloat_AsDouble(w);
		    features_array[i] = PyList_GetItem(features, i);
		    Py_XINCREF(features_array[i]);
		} else {
		    PyErr_SetString(PyExc_TypeError, "weights must be floats");
		    	for (j = i; j > 0; j++) {
				Py_XDECREF(features_array[i]);
		    }
		    free(weights_array);
		    free(features_array);
		    return NULL;
		}
    }
    
    // Finally, create and return the (pointer to) the signature_t structure.
    // ($1 is a placeholder for the variable that receives the converted value.) 
    $1 = (signature_t *) malloc(sizeof(signature_t));
    $1->n = (int) features_count;
    $1->Features = features_array;
    $1->Weights = weights_array;
}


/**
 * Destructor for the automatically constructed signature_t* function argument.
 **/
%typemap(freearg) signature_t * {
	if ($1 != NULL) {
	    free((PyObject **) $1->Features);
	    free((float *) $1->Weights);
	    free((signature_t *) $1);
    }
}


/**
 * Automatic converter for the ground distance callback argument that the
 * EMD implementation expects.
 *
 * The converter stores the given Python callable object p in a global
 * variable 'distance_callback' and then returns a pointer to the (one)
 * C function 'distance_from_callback' that uses p to compute the distance.
 * 
 * The reason for this indirect approach is that Python callables cannot
 * be cast into C function pointers directly.
 */
%typemap(in) float (*)(feature_t *, feature_t *)  {
    PyObject *new_distance_callback = $input;
    
    if (!PyCallable_Check(new_distance_callback)) {
		PyErr_SetString(PyExc_TypeError, "parameter must be callable");
		// TODO Additional checks about accepted parameters go here.
		return NULL;
    }
    Py_XINCREF(new_distance_callback);			/* Add a reference to new callback */
    if (distance_callback != NULL)
		Py_XDECREF(distance_callback);  		/* Dispose of previous callback */
    distance_callback = new_distance_callback;	/* Remember new callback */
    
    // Always return the same function (that uses the callback variable).
    $1 = &distance_from_callback;
}


/**
 * Expose the EMD function with a reduced argument list, ignoring the
 * flow output for now.
 **/
%rename(emd) emd_wrap;		// Even though the wrapper is called 'emd_wrap',
							// it should show up as 'emd' in Python.
%inline %{
	float emd_wrap(signature_t *Signature1, signature_t *Signature2,
		   			float (*ground_distance)(feature_t *, feature_t *))
	{
		// This emd() function is the actual implementation.
	    return emd(Signature1, Signature2, ground_distance, 0, 0);
	}
%}
