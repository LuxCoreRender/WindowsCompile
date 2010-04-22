import os, sys
import shutil
from xml.dom.minidom import parse

projroot = os.path.normcase(os.getcwd())

if not os.path.isfile(os.path.join(projroot, 'core.vcproj')):
		print 'Error: core.vcproj not found'
		sys.exit()

luxroot = os.path.normcase(os.path.abspath(os.path.join(projroot, '../..')))

print projroot, luxroot

#sys.exit()

doc = None

def relpath(path, start):
	common = os.path.commonprefix([path, start])
	if common == '':
		return None
	crelp = path.replace(common, '')
	crels = start.replace(common, '')
	prefix = ''
	for pi in crels.split(os.sep):
		prefix = '..' + os.sep + prefix
	
	#rp = prefix + crelp
	#print rp, os.path.relpath(path, start)
	return rp


def isFilterNode(n):
		return n.nodeType == n.ELEMENT_NODE and n.nodeName == 'Filter'

def isFileNode(n):
		return n.nodeType == n.ELEMENT_NODE and n.nodeName == 'File'

def getNodeByName(nodes, name):
	n = [n for n in nodes if n.getAttribute('Name') == name]
	if len(n) < 1:
				return None
	return n[0]


def walkDirectory(path, root, fileext):

	#print path

	# get list of all items in project node
	filenodes = filter(isFileNode, root.childNodes)

	fnodes = {}
	for fn in filenodes:
		fname = os.path.normcase(os.path.normpath(os.path.join(projroot, fn.getAttribute('RelativePath'))))
		fnodes[fname] = fn

	dlist = [os.path.join(path, os.path.normcase(di)) for di in os.listdir(path)]

	dirs =  filter(os.path.isdir, dlist)
	files = filter(os.path.isfile, dlist)

	#print 'Files'
	#print map(os.path.basename, files)

	for f in files:
		ext = os.path.splitext(f)[1]
		if ext <> fileext:
			continue
		# file already in project
		if f in fnodes:
			continue		
		fnode = doc.createElement('File')
		rfpath = relpath(f, projroot)
		fnode.setAttribute('RelativePath', rfpath)
		root.appendChild(fnode)
		print rfpath


	filternodes = filter(isFilterNode, root.childNodes)

	#print 'Dirs'
	
	for d in dirs:
		dname = os.path.basename(d)
		if dname in ['.hg', 'pbrtattic']:
			continue
		droot = getNodeByName(filternodes, dname)
		if droot == None:
			droot = doc.createElement('Filter')
			droot.setAttribute('Name', dname)
			root.appendChild(droot)
		walkDirectory(d, droot, fileext)
		if len(droot.childNodes) < 1:
			root.removeChild(droot)
			droot.unlink()
		


def walkRootDirectory(path, root, fileext):

	dlist = filter(os.path.isdir, [os.path.normcase(os.path.join(path, di)) for di in os.listdir(path)])
	filternodes = filter(isFilterNode, root.childNodes)

	for ditem in dlist:
		droot = getNodeByName(filternodes, os.path.basename(ditem))
		if droot == None:
				continue
		walkDirectory(ditem, droot, fileext)


print 'Parsing project file'

outf = open('core.xml', 'w+')

doc = parse('core.vcproj')

shutil.move('core.vcproj', 'core.vcproj.backup')

doc.writexml(outf)
outf.close()

filesnode = doc.getElementsByTagName('Files')[0]
filesfilternodes = filter(isFilterNode, filesnode.childNodes)

headernode = getNodeByName(filesfilternodes, 'Header Files')
sourcenode = getNodeByName(filesfilternodes, 'Source Files')

walkRootDirectory(os.path.join(luxroot, 'lux'), headernode, '.h')
walkRootDirectory(os.path.join(luxroot, 'lux'), sourcenode, '.cpp')

outf = open('core.vcproj', 'w+')
doc.writexml(outf)
outf.close()
