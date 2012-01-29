import opti

def test(current, total):
	print 'blah'
	print "Progress:", current, "/", total

opti.add_progress_handler(test)
print 'added'
print dir(opti)
opti.progress(2L, 20L)