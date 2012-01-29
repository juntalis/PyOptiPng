#ifndef __PYX_HAVE__optipng
#define __PYX_HAVE__optipng


#ifndef __PYX_HAVE_API__optipng

#ifndef __PYX_EXTERN_C
  #ifdef __cplusplus
    #define __PYX_EXTERN_C extern "C"
  #else
    #define __PYX_EXTERN_C extern
  #endif
#endif

__PYX_EXTERN_C DL_IMPORT(struct opng_options) c_options;
__PYX_EXTERN_C DL_IMPORT(PyObject) *opng_handlers_log;
__PYX_EXTERN_C DL_IMPORT(PyObject) *opng_handlers_fatal;
__PYX_EXTERN_C DL_IMPORT(PyObject) *opng_handlers_progress;

#endif /* !__PYX_HAVE_API__optipng */

#if PY_MAJOR_VERSION < 3
PyMODINIT_FUNC initoptipng(void);
#else
PyMODINIT_FUNC PyInit_optipng(void);
#endif

#endif /* !__PYX_HAVE__optipng */
