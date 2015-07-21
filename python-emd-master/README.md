Earth Mover's Distance Python2 Module
=====================================

This module provides a function for computing the
[earth mover's distance (EMD)][emd] in [Python2][python].  It wraps
[Yossi Rubner's C implementation][rubner_emd] of the EMD into a Python
module using a custom [SWIG interface wrapper][swig].

The EMD is a distance measure between two probability distributions.
It can be used, for example, to retrieve similar images from a
database.  However, this implementation is not limited to images or
histograms; it can represent distributions over any user-defined
features, using any user-defined ground distance.  Please see the
[original homepage][rubner_emd] for more explanations and references.


Installation
------------

Building the module requires the following:
- Python2 C headers (`python-dev`)
- C compiler and linker, as well as Make (`build-essential`)
- [SWIG Simple Wrapper and Interface Generator][swig] (`swig`)
- EMD source code and interface definition (`emd.h`, `emd.c`, and
  `emd.i` in this repository)
  
The name in parentheses after the first three entries is the name of
the Debian/Ubuntu Linux package that contains the required files.

If all requirements are met, the module can be built using Make.
Simply execute `make` in the directory that contains the EMD source
code and interface definition.  The output should look similar to the
following:

~~~~
>>> Building object file 'emd.o'.
    cc -o emd.o -c emd.c -fPIC -I/usr/include/python2.7 -I/usr/include/python2.7 

>>> Generating C interface
swig -python emd.i

>>> Building object file 'emd_wrap.o'.
    cc -o emd_wrap.o -c emd_wrap.c -fPIC -I/usr/include/python2.7 -I/usr/include/python2.7 

>>> Linking wrapper library '_emd.so'.
    ld -shared -o _emd.so emd.o emd_wrap.o

rm emd_wrap.o emd.o emd_wrap.c
~~~~

You can ignore warnings about redefinitions of `INFINITY` and extra
tokens at the end of include statements.  If everything went well, the
now directory contains the C library `_emd.so` and its Python wrapper
`emd.py`.


Usage Example
-------------

The included `example1.py` is a port of `example1.c`.  It demonstrates
the basic use of the EMD module.  Simply run the script with the
Python2 interpreter:
~~~~
$ python2 example1.py 
160.542770386
~~~~


Interface
---------

The function `emd` in the `emd` module computes the EMD.  (I bet you
were surprised by this fact.)  It accepts two pairs of feature and
weight lists, and a callable for computing the ground distance.

~~~~
from emd import emd
print emd( (features1, weights1), (features2, weights2), distance)
~~~~

In above code, `features1` and `features2` are lists of arbitrary
Python objects.  The implementation invokes the callable `distance` on
pairs of feature objects to compute the distance matrix.  Each feature
object is assigned a weight to characterize the distribution.

The implementation treats objects as opaquely as possible.  The only
limitations are:
- `features1` and `weights1` are lists of the same length.  The
  entries of `weights1` must be floating point numbers; `features1`
  can contain arbitrary objects, but the `distance` function must be
  able to process them.  Similarly for `features2` and `weights2`.
- The `distance` argument is a callable object (for example a
  function) that accepts two arguments (from the `features` lists) and
  returns a floating point number.

See `example1.py` for a filled-in example.


Limitations
-----------

- The C implementation uses `float` as its fundamental data type for
  distances and weights.  The (typically `double`) floating point
  objects of Python will be down-cast and lose precision.
- See `emd.h` for the hard-coded definitions of maximum signature
  size, maximum iteration count, and computational constants.
- Currently, the wrapper ignores the flow output argument that is
  available in the C implementation.
- The wrapper is *not* suited for concurrent execution.  It uses a
  global variable for the distance callback function, so calling `emd`
  from concurrent threads will result in undefined behavior.


Copyright
---------

Only the wrapper code, the Makefile, the Python version of
`example1.c`, and this document were written by me and consequently
are (c) copyrighted by Peter Dinges.  These files are available under
the open-source [MIT License][mit-license].

[Yossi Rubner][rubner] is the author of the C code that performs the
actual computation.  I have included his source code in this
repository because I am unsure about the future availability of his
homepage.  (I could not reach him via email.)


[python]: http://python.org/ "Python programming language"
[swig]: http://swig.org/ "Simple Wrapper and Interface Generator"
[emd]: http://en.wikipedia.org/wiki/Earth_mover's_distance "Explanation of the Earth Mover's Distance"
[rubner_emd]: http://ai.stanford.edu/~rubner/emd/default.htm "EMD implementation in C"
[rubner]: http://ai.stanford.edu/~rubner/
[mit-license]: http://opensource.org/licenses/mit-license.php
