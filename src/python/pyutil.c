#include "pyutil.h"
#include "optipngmodule.h"

#ifndef _WIN32
#	define _vscprintf(f,a) vsprintf(NULL,f,a) 
#endif

#define HANDLERS(t) opng_handlers_##t

static struct opng_ui ui;
static int start_of_line;

static void wrapped_ctrl_fn(int cntrl_code)
{
	const char *log_str;
	PyObject* log_handlers;
	Py_ssize_t i = 0;
	Py_ssize_t count;
	
	log_handlers = HANDLERS(log);
	if((log_handlers == NULL) || (!PyList_CheckExact(log_handlers))) return;
	
	count = PyList_Size(log_handlers);
	if (count <= 0) return;

	if (cntrl_code == '\r') {
		/* CR: reset line in console, new line in log file. */
		log_str = "\n";
		start_of_line = 1;
	} else if (cntrl_code == '\v') {
		/* VT: new line if current line is not empty, nothing otherwise. */
		if (!start_of_line) {
			log_str = "\n";
			start_of_line = 1;
		} else log_str = "";
	} else if (cntrl_code < 0 && cntrl_code > -80 && start_of_line) {
		log_str = "";
	} else {
		/* Unhandled control code (due to internal error): show err marker. */
		log_str = "<?>";
	}

	for(i = 0; i < count; i++) {
		PyObject *callback = (PyObject*) PyList_GetItem(log_handlers, i);
		if(!PyCallable_Check(callback)) continue;
		PyObject_CallFunction(callback, (char*) "s", log_str);
	}
}

static void wrapped_err_fn(const char *msg)
{
	Py_ssize_t i;
	Py_ssize_t count;
	PyObject* err_handlers;
	err_handlers = HANDLERS(fatal);
	if((err_handlers == NULL) ||
		(!PyList_CheckExact(err_handlers)) ||
		((count = PyList_Size(err_handlers)) <= 0)) {
			
		PyErr_SetString(PyExc_Exception, msg);
		return;
	} else {
		for(i = 0; i < count; i++) {
			PyObject *callback = (PyObject*) PyList_GetItem(err_handlers, i);
			if(!PyCallable_Check(callback)) continue;
			PyObject_CallFunction(callback, (char*) "s", msg);
		}
	}
}

static void wrapped_log_fn(const char *fmt, ...)
{
	int len;
	Py_ssize_t i;
	size_t bufflen;
	va_list args;
	char* buffer;
	Py_ssize_t count;
	PyObject* log_handlers;

	log_handlers = HANDLERS(log);
	if((log_handlers == NULL) ||
		(!PyList_CheckExact(log_handlers)) ||
		((count = PyList_Size(log_handlers)) <= 0))
			return;
	

	va_start(args, fmt);
	len = _vscprintf( fmt, args ) + 1; // // terminating '\0'
	if (!fmt[0] || (len == 0)) return;
	start_of_line = (fmt[strlen(fmt) - 1] == '\n') ? 1 : 0;
	
	bufflen = len * sizeof(char);
	buffer = (char*)malloc(bufflen);
	memset((void*)buffer, 0, bufflen);
	vsprintf( buffer, fmt, args );
	va_end(args);
	
	for(i = 0; i < count; i++) {
		PyObject *callback = (PyObject*) PyList_GetItem(log_handlers, i);
		if(!PyCallable_Check(callback)) continue;
		PyObject_CallFunction(callback, (char*) "s", buffer);
	}
	free(buffer);
}

static void wrapped_progress_fn(unsigned long current_step, unsigned long total_steps)
{
	Py_ssize_t i;
	Py_ssize_t count;
	PyObject* progress_handlers;
	
	if(!(current_step && total_steps))
		return;

	progress_handlers = HANDLERS(progress);
	if((progress_handlers == NULL) ||
		(!PyList_CheckExact(progress_handlers)) ||
		((count = PyList_Size(progress_handlers)) <= 0))
		return;
	
	for(i = 0; i < count; i++) {
		PyObject *callback = (PyObject*) PyList_GetItem(progress_handlers, i);
		if(!PyCallable_Check(callback)) continue;
		PyObject_CallFunction(callback, (char*)"KK", (unsigned PY_LONG_LONG)current_step, (unsigned PY_LONG_LONG)total_steps);
	}
	
}

int initialize_internals()
{
	if(ui.print_cntrl_fn == NULL) {
		ui.panic_fn = wrapped_err_fn;
		ui.printf_fn = wrapped_log_fn;
		ui.print_cntrl_fn = wrapped_ctrl_fn;
		ui.progress_fn = wrapped_progress_fn;
	}
	return opng_initialize(&c_options, &ui);
}


int finalize_internals()
{
	return opng_finalize();
}

/*
void wrapped_optimize(char* file)
{

}
*/

/*
if (!PyCallable_Check(callback)) {
	PyErr_SetString(PyExc_TypeError, "parameter must be callable");
	return;
}*/