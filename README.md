# PyOptipng

Python C-extension wrapping the internals of [OptiPng](http://optipng.sourceforge.net/) to allow optimizing the size of image files from Python. Currently, I've set up a simple (hacked up) Cython wrapper around the engine. The original Cython source can be found in src/python. ~~I did, however, comment two lines of code from the originally generated code so that the classes Engine and Options are not exposed to the calling code for construction.~~ Since the module stores a reference to the real engine internals at the C-side and at module level, this shouldn't be an issue. When I have more time, I'll put together a proper C wrapper, but for now, this should do.

I also need to put together a setup script. I don't current have access to a Linux machine, and I'd really rather not create a new virtual machine, so if someone could attempt to build the module on Linux/Mac OSX, I'd appreciate it.

OptiPng Copyright (C) 2001-2011 Cosmin Truta.

Any code by me is released under the [Do What The Fuck You Want To Public License](http://sam.zoy.org/wtfpl/). Have fun.

## TODO:

* Write a setup.py script.
* Eliminate the current Cython wrapper in place of actual C code.
* Trim away some of the unnecessary code from optipng for dealing with folders, etc. (Things easily dealt with from the calling script)
* Modify the internals to provide less of a monotholic, singleton engine, thus allow multiple engines to be created and run in parallel.

Simple Example Usage:

	#!python
	import optipng
	def test(current, total):
		print 'Progress:', current, '/', total

	optipng.add_progress_handler(test)
	optipng.options.output_dir = 'out'
	optipng.options.optimization_level = 7
	optipng.engine += 'data\\test1.png'
	optipng.engine += 'data\\test2.png'
	optipng.engine += 'data\\test3.png'
	optipng.engine += 'data\\test4.png'
	optipng.engine += 'data\\test5.png'
	optipng.engine += 'data\\test6.png'
	optipng.engine.execute()