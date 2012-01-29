# Cythonic wrappers around optipng.h & optipngmodule.h
include "optipng.pxi"
from cpython.object cimport PyCallable_Check
from cpython.list cimport PyList_CheckExact
from cpython.string cimport PyString_Check
from cpython.function cimport PyFunction_Check
from cpython.method cimport PyMethod_Check

cdef extern from 'proginfo.h' nogil:
	char* PROGRAM_VERSION

cdef extern from 'pyutil.h':
	#void wrapped_optimize(char *)
	int initialize_internals()
	int finalize_internals()

cdef public opng_options c_options
cdef bint engine_locked = False

cdef public object opng_handlers_log = []
cdef public object opng_handlers_fatal = []
cdef public object opng_handlers_progress = []

cdef bint add_handler(object root, object handler):
	if handler is not None and (PyMethod_Check(handler) or PyFunction_Check(handler)):
		root.append(handler)
		return true
	return false

def add_log_handler(handler):
	global opng_handlers_log
	if not add_handler(opng_handlers_log, handler):
		raise TypeError('Handlers must be callable objects. (Functions/Methods)')

def add_fatal_handler(handler):
	global opng_handlers_fatal
	if not add_handler(opng_handlers_fatal, handler):
		raise TypeError('Handlers must be callable objects. (Functions/Methods)')

def add_progress_handler(handler):
	global opng_handlers_progress
	if not add_handler(opng_handlers_progress, handler):
		raise TypeError('Handlers must be callable objects. (Functions/Methods)')

cdef int wrapped_optimize(char* img):
	return opng_optimize(<const_char*>img)
cdef class Options(object):
	# TODO:
	#bitset_t compr_level_set
	#bitset_t mem_level_set
	#bitset_t strategy_set
	#bitset_t filter_set
	#cdef public int window_bits

	def __cinit__(self):
		global c_options
		c_options.fix = False
		c_options.force = False
		c_options.full = False
		c_options.keep = False
		c_options.interlace = -1
		# bit_depth_reduction
		c_options.nb = False
		# color_type_reduction
		c_options.nc = False
		# palette_reduction
		c_options.np = False
		# idat_recoding
		c_options.nz = False
		c_options.preserve = False
		c_options.simulate = False
		c_options.snip = False
		c_options.verbose = False
		c_options.optim_level = OPNG_OPTIM_LEVEL_DEFAULT
		c_options.window_bits = 15
		c_options.compr_level_set = 9
		c_options.mem_level_set = 8
		c_options.strategy_set = 0
		c_options.filter_set = 0
		# output_dir
		c_options.dir_name = NULL

	def __dealloc__(self):
		raise Exception('Cannot delete builtin objects.')

	property fix:
		def __get__(self):
			return c_options.fix

		def __set__(self, bint value):
			global c_options, engine_locked
			assert(not engine_locked)
			c_options.fix = value

	property force:
		def __get__(self):
			return c_options.force

		def __set__(self, bint value):
			global c_options, engine_locked
			assert(not engine_locked)
			c_options.force = value

	property full:
		def __get__(self):
			return c_options.full

		def __set__(self, bint value):
			global c_options, engine_locked
			assert(not engine_locked)
			c_options.full = value

	property keep:
		def __get__(self):
			return c_options.keep

		def __set__(self, bint value):
			global c_options, engine_locked
			assert(not engine_locked)
			c_options.keep = value

	property interlace:
		def __get__(self):
			return c_options.interlace

		def __set__(self, int value):
			global c_options, engine_locked
			assert(not engine_locked)
			if value < 0 or value > 1:
				raise Exception('PNG interlace type invalid. Valid options: 0-1')
			c_options.interlace = value

	property bit_depth_reduction:
		def __get__(self):
			return not c_options.nb

		def __set__(self, bint value):
			global c_options, engine_locked
			assert(not engine_locked)
			c_options.nb = not value

	property color_type_reduction:
		def __get__(self):
			return not c_options.nc

		def __set__(self, bint value):
			global c_options, engine_locked
			assert(not engine_locked)
			c_options.nc = not value

	property palette_reduction:
		def __get__(self):
			return not c_options.np

		def __set__(self, bint value):
			global c_options, engine_locked
			assert(not engine_locked)
			c_options.np = not value

	property idat_recoding:
		def __get__(self):
			return not c_options.nz

		def __set__(self, bint value):
			global c_options, engine_locked
			assert(not engine_locked)
			c_options.nz = not value

	property preserve:
		def __get__(self):
			return c_options.preserve

		def __set__(self, bint value):
			global c_options, engine_locked
			assert(not engine_locked)
			c_options.preserve = value

	property simulate:
		def __get__(self):
			return c_options.simulate

		def __set__(self, bint value):
			global c_options, engine_locked
			assert(not engine_locked)
			c_options.simulate = value

	property snip:
		def __get__(self):
			return c_options.snip

		def __set__(self, bint value):
			global c_options, engine_locked
			assert(not engine_locked)
			c_options.snip = value

	property verbose:
		def __get__(self):
			return c_options.verbose

		def __set__(self, bint value):
			global c_options, engine_locked
			assert(not engine_locked)
			c_options.verbose = value

	property optimization_level:
		def __get__(self):
			return c_options.optim_level

		def __set__(self, int value):
			global c_options, engine_locked
			assert(not engine_locked)
			if value < 0 or value > 7:
				raise Exception('Invalid optimization level specified. Valid options: 0-7')
			c_options.optim_level = value

	property output_dir:
		def __get__(self):
			cdef char* check = c_options.dir_name
			if c_options.dir_name == NULL:
				return ''
			return c_options.dir_name

		def __set__(self, char* value):
			global c_options, engine_locked
			assert(not engine_locked)
			c_options.dir_name = value

options = Options()

cdef class Engine(object):
	cdef object __weakref__
	cdef readonly char* version
	cdef readonly object current_file
	cdef object queue

	def __cinit__(self):
		self.version = PROGRAM_VERSION
		self.queue = []
		self.current_file = None

	def __dealloc__(self):
		raise Exception('Cannot delete builtin objects.')

	def execute(self):
		if len(self.queue) > 0:
			engine_locked = True
			if initialize_internals():
				raise Exception('Cannot initialize optimization engine')
			self.queue = list(set(self.queue))
			while len(self.queue):
				img = self.queue[-1]
				del self.queue[-1]
				self.current_file = img
				wrapped_optimize(img)
			self.current_file = None
			if finalize_internals():
				raise Exception('Cannot finalize optimization engine')
			engine_locked = False

	def __iadd__(self, other):
		if PyString_Check(other):
			self.queue.append(other)
		elif PyList_CheckExact(other):
			self.queue += other
		else:
			raise Exception('Don\'t know what to do with the value. Valid types: List,String')
		return self

	property images:
		def __get__(self):
			return self.queue

		def __set__(self, object value):
			global engine_locked
			if PyList_CheckExact(value):
				assert(not engine_locked)
				self.queue = value
			elif PyString_Check(value):
				self.queue.append(value)
			else:
				raise Exception('Don\'t know what to do with the value. Valid types: List,String')

	property log_handlers:
		def __get__(self):
			return opng_handlers_log

		def __set__(self, object value):
			global opng_handlers_log
			cdef object new_value = value
			if PyList_CheckExact(value):
				del opng_handlers_log[:]
				for entry in <list>new_value:
					add_log_handler(entry)
			else:
				add_log_handler(value)

		def __del__(self):
			global opng_handlers_log
			del opng_handlers_log[:]

	property fatal_handlers:
		def __get__(self):
			return opng_handlers_fatal

		def __set__(self, object value):
			global opng_handlers_fatal
			cdef object new_value = value
			if PyList_CheckExact(value):
				del opng_handlers_fatal[:]
				for entry in <list>new_value:
					add_log_handler(entry)
			else:
				add_log_handler(value)

		def __del__(self):
			global opng_handlers_fatal
			del opng_handlers_fatal[:]

	property progress_handlers:
		def __get__(self):
			return opng_handlers_progress

		def __set__(self, object value):
			global opng_handlers_progress
			cdef object new_value = value
			if PyList_CheckExact(value):
				del opng_handlers_progress[:]
				for entry in <list>new_value:
					add_log_handler(entry)
			else:
				add_log_handler(value)

		def __del__(self):
			global opng_handlers_progress
			del opng_handlers_progress[:]

engine = Engine()

