import sys, os

root_dir = os.path.dirname(os.path.abspath(os.path.dirname(__file__)))

def main(config = 'release'):
	bindir = os.path.join(root_dir, 'bin', config.title())
	sys.path.insert(0, bindir)
	import optipng
	help(optipng)
	
	print 'Press enter to continue.'
	raw_input()

if __name__ == '__main__':
	sys.argv = [(lambda a: a.lower())(arg) for arg in sys.argv]
	if len(sys.argv) == 1:
		main()
	elif sys.argv[1] in ['debug','release']:
		main(sys.argv[1])
	else:
		print 'Usage: %s [Release|Debug]' % sys.argv[0]