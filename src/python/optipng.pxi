# Some externs that I didn't want clogging up the main module file.
from libc.stdlib cimport const_char

cdef extern from* nogil:
	ctypedef unsigned long ulong "unsigned long"
	ctypedef unsigned long uchar "unsigned char"

DEF false = 0
DEF true = 1

cdef extern from 'optipng.h':
	ctypedef unsigned int bitset_t
	#	OptiPNG 0.6.5: Advanced PNG optimizer.
	#	Copyright (C) 2001-2011 Cosmin Truta.
	#
	#	Synopsis:
	#		optipng [options] files ...
	#	Files:
	#		Image files of type: PNG, BMP, GIF, PNM or TIFF
	#	Basic options:
	#		-?, -h, -help	show this help
	#		-o <level>		optimization level (0-7)		default 2
	#		-v			verbose mode / show copyright and version info
	#	General options:
	#		-fix		enable error recovery
	#		-force		enforce writing of a new output file
	#		-keep		keep a backup of the modified files
	#		-preserve		preserve file attributes if possible
	#		-quiet		quiet mode
	#		-simulate		simulation mode
	#		-snip		cut one image out of multi-image or animation files
	#		-out <file>		write output file to <file>
	#		-dir <directory>	write output file(s) to <directory>
	#		-log <file>		log messages to <file>
	#		--			stop option switch parsing
	#	Optimization options:
	#		-f  <filters>	PNG delta filters (0-5)			default 0,5
	#		-i  <type>		PNG interlace type (0-1)		default <input>
	#		-zc <levels>	zlib compression levels (1-9)		default 9
	#		-zm <levels>	zlib memory levels (1-9)		default 8
	#		-zs <strategies>	zlib compression strategies (0-3)	default 0-3
	#		-zw <window size>	zlib window size (32k,16k,8k,4k,2k,1k,512,256)
	#		-full		produce a full report on IDAT (might reduce speed)
	#		-nb			no bit depth reduction
	#		-nc			no color type reduction
	#		-np			no palette reduction
	#		-nx			no reductions
	#		-nz			no IDAT recoding
	#	Optimization details:
	#		The optimization level presets
	#			-o0  <=>  -o1 -nx -nz
	#			-o1  <=>  [use the libpng heuristics]	(1 trial)
	#			-o2  <=>  -zc9 -zm8 -zs0-3 -f0,5	(8 trials)
	#			-o3  <=>  -zc9 -zm8-9 -zs0-3 -f0,5	(16 trials)
	#			-o4  <=>  -zc9 -zm8 -zs0-3 -f0-5	(24 trials)
	#			-o5  <=>  -zc9 -zm8-9 -zs0-3 -f0-5	(48 trials)
	#			-o6  <=>  -zc1-9 -zm8 -zs0-3 -f0-5	(120 trials)
	#			-o7  <=>  -zc1-9 -zm8-9 -zs0-3 -f0-5	(240 trials)
	#		The libpng heuristics
	#			-o1  <=>  -zc9 -zm8 -zs0 -f0		(if PLTE is present)
	#			-o1  <=>  -zc9 -zm8 -zs1 -f5		(if PLTE is not present)
	#		The most exhaustive search (not generally recommended)
	#		  [no preset] -zc1-9 -zm1-9 -zs0-3 -f0-5	(1080 trials)
	#	Examples:
	#		optipng file.png				(default speed)
	#		optipng -o5 file.png			(moderately slow)
	#		optipng -o7 file.png			(very slow)
	#		optipng -i1 -o7 -v -full -sim experiment.png

	cdef struct opng_options:
		bint fix
		bint force
		bint full
		int interlace
		bint keep
		bint nb
		bint nc
		bint np
		bint nz
		bint preserve
		bint simulate
		bint snip
		bint verbose
		int optim_level
		bitset_t compr_level_set
		bitset_t mem_level_set
		bitset_t strategy_set
		bitset_t filter_set
		int window_bits
		char * out_name
		char * dir_name

	int opng_optimize(const_char *infile_name)

DEF OPNG_OPTIM_LEVEL_DEFAULT = 2
DEF OPNG_OPTIM_LEVEL_MIN = 0
DEF OPNG_OPTIM_LEVEL_MAX = 7

DEF OPNG_COMPR_LEVEL_MIN = 1
DEF OPNG_COMPR_LEVEL_MAX = 9
DEF OPNG_COMPR_LEVEL_SET_MASK = ((1 << (9+1)) - (1 << 1)) # 0x03fe

DEF OPNG_MEM_LEVEL_MIN = 1
DEF OPNG_MEM_LEVEL_MAX = 9
DEF OPNG_MEM_LEVEL_SET_MASK = ((1 << (9+1)) - (1 << 1)) # 0x03fe

DEF OPNG_STRATEGY_MIN = 0
DEF OPNG_STRATEGY_MAX = 3
DEF OPNG_STRATEGY_SET_MASK = ((1 << (3+1)) - (1 << 0)) # 0x000f

DEF OPNG_FILTER_MIN = 0
DEF OPNG_FILTER_MAX = 5
DEF OPNG_FILTER_SET_MASK = ((1 << (5+1)) - (1 << 0)) # 0x003f