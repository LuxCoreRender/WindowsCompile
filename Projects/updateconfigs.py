import os, sys
import shutil
from xml.dom.minidom import parse

projroot = os.path.normcase(os.getcwd())

if not os.path.isfile(os.path.join(projroot, 'core.vcproj')):
		print 'Error: core.vcproj not found'
		sys.exit()

luxroot = os.path.normcase(os.path.abspath(os.path.join(projroot, '../..')))

def isToolNode(n):
	return n.nodeType == n.ELEMENT_NODE and n.nodeName == 'Tool'

def isConfigurationNode(n):
	return n.nodeType == n.ELEMENT_NODE and n.nodeName == 'Configuration'

def getNodeByName(nodes, name):
	n = [n for n in nodes if n.getAttribute('Name') == name]
	if len(n) < 1:
				return None
	return n[0]

def attrsToDict(n):
	out={}
	for k,v in dict(n.attributes).items():
		out[k] = v.value
	return out

def walkConfigs(RootNode):
	confignodes = filter(isConfigurationNode, RootNode.childNodes)
	cnodes = {}
	config_names = []
	platform_names = []
	for cn in confignodes:
		print(cn.getAttribute('Name'))
		configname, platform = cn.getAttribute('Name').split('|')
		if configname not in config_names:
			config_names.append(configname)
		if platform not in platform_names:
			platform_names.append(platform)
		if platform not in cnodes.keys():
			cnodes[platform] = {}
		if configname not in cnodes[platform].keys():
			cnodes[platform][configname] = {}
		toolnodes = filter(isToolNode, cn.childNodes)
		for tn in toolnodes:
			if tn.getAttribute('Name') == 'VCCLCompilerTool':
				cnodes[platform][configname]['CompilerSettings'] = attrsToDict(tn)
			if tn.getAttribute('Name') == 'VCLinkerTool':
				cnodes[platform][configname]['LinkerSettings'] = attrsToDict(tn)
			if tn.getAttribute('Name') == 'VCResourceCompilerTool':
				cnodes[platform][configname]['ResourceCompilerSettings'] = attrsToDict(tn)
		
	return config_names, platform_names, cnodes

project_xmldoc = parse('core.vcproj')

e_Configurations = project_xmldoc.getElementsByTagName('Configurations')[0]

configs, platforms, configurations = walkConfigs(e_Configurations)

print('Configurations: %s' % ', '.join(configs))
print('Platforms: %s' % ', '.join(platforms))

