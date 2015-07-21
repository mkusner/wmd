# Makefile for the SWIG Python wrapper for Yossi Rubner's EMD implementation.
#
# Copyright (c) 2011 Peter Dinges <pdinges@acm.org>
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE. 
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# $Id$

WRAPPERS := _emd.so emd.py
LIBS =
INCLUDES := $(shell python2-config --includes)

CC = cc
LD = ld
CFLAGS = -fPIC

all: $(WRAPPERS)

_%.so: %.o %_wrap.o
	@echo ">>> Linking wrapper library '$(@)'."
	@echo -n "    "
	$(LD) -shared -o $@ $^
	@echo

%.o: %.c
	@echo ">>> Building object file '$(@)'."
	@echo -n "    "
	$(CC) -o $@ -c $< $(CFLAGS) $(INCLUDES) $(LIBS)
	@echo

%_wrap.c %.py: %.i %.h
	@echo ">>> Generating C interface"
	swig -python $<
	@echo

.PHONY: clean

clean:
	rm -f $(WRAPPERS) *.o *_wrap.c *.pyc *.pyo
	rm -rf __pycache__ 

mrproper: clean
	rm -f *~
