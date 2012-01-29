#ifndef _OPTIPNG_PY_H_
#define _OPTIPNG_PY_H_
#pragma once

#include <Python.h>
#include "optipng.h"

/* This program is free software. It comes without any warranty, to
 * the extent permitted by applicable law. You can redistribute it
 * and/or modify it under the terms of the Do What The Fuck You Want
 * To Public License, Version 2, as published by Sam Hocevar. See
 * http://sam.zoy.org/wtfpl/COPYING for more details. */

#ifdef __cplusplus
#	define PYOPNG_EXPORT extern "C"
#else
#	define PYOPNG_EXPORT extern
#endif

// TODO: Implement the internal collection of images
// in the queue as a linked list.
/*
struct file_list {
	const char* file;
	struct handler_list* next;
};

PYOPNG_EXPORT void wrapped_optimize(char* file);
*/

PYOPNG_EXPORT int initialize_internals();
PYOPNG_EXPORT int finalize_internals();

#ifdef __cplusplus
#	undef PYOPNG_EXPORT
#endif

#endif
