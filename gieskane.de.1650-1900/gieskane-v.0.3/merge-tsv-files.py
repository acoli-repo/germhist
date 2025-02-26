import sys,os,re,argparse,json,traceback
from pprint import pprint

args=argparse.ArgumentParser(description="combine word-level CoNLL annotations with TSV-encoded phrase structures and, optionally, grammatical roles")
args.add_argument("TOKENS_CONLL", type=str, help="token-level annotations, CoNLL format")
args.add_argument("TREE_TSV", type=str, help="we expect PARENT<TAB>CAT<TAB>CHILD, with CHILD matching PARENTS from TREE_TSV or last column of TOKENS_CONLL")
args.add_argument("ROLES_TSV", type=str, nargs="?", help="(optional) TSV file with grammatical roles, we expect PARENT<TAB>CHILD<TAB>EDGE", default=None)
args=args.parse_args()

def _tree2conll(tree, indent=""):
	# we do PTB conversion

	if isinstance(tree,str):
		return tree.rstrip()+"\n"

	if isinstance(tree, dict) and len(tree)==1:
		for key,val in tree.items():
			return f"{indent}({key}\n"+_tree2conll(val,indent+"  ").rstrip()+f"\n{indent})\n"

	if isinstance(tree, list) and len(tree)>0:
		terminal_row=True

		for x in tree:
			if not isinstance(x,str): 
				terminal_row=False
				break

		if terminal_row:
			return f"{indent}"+"\t".join(tree)+"\n"
		
		return f"{indent}"+f"\n{indent}".join([_tree2conll(sub,indent+"  ").rstrip() for sub in tree])+"\n"

	raise Exception(f"cannot process {tree}")

def _merge2tree(parent2child_roles,node2cat,root,_nodes=[]):
	""" nodes is an internal argument to break cycles """

	if not isinstance(root,str):
		return root
	if not root in parent2child_roles:
		return root

	result={}
	cat="_"
	if root in node2cat:
		cat=node2cat[root]
	result[cat]=[]

	for nr in range(len(parent2child_roles[root])):
		try: 
			child,role = parent2child_roles[root][nr]
			if not child in _nodes:
				sub=_merge2tree(parent2child_roles,node2cat,child,_nodes=_nodes+[child])
				if not role in ["","_"]:
					if isinstance(sub,dict) and len(sub)==1:
						sub={ key+"-"+role : val for key,val in sub.items()}
					else:
						sub={ "???-"+role : sub }
				_nodes.append(child)
		except: # plain lines
#			traceback.print_exc()
#			sys.exit()
			sub=parent2child_roles[root][nr]
		result[cat].append(sub)

	return result


def spellout(buffer):
	""" buffer is a list of conll rows, optionally extended with phrase structure syntax 
		we revert the entire structure to start from the root
		we assume a projective tree
	"""

	roots=[]
	parent2child_roles={}
	node2cat={}
	for row in buffer:
		root=row[-2]
		if not root in roots:
			roots.append(root)
		parent=None

		role="root"		
		node=row[-2]
		cat=row[-1]
		row=row[:-2]
		
		while node.startswith("salt:/"):
			node2cat[node]=cat

			parent=node
			role=row[-1]
			cat=row[-2]
			node=row[-3]

			if not parent in parent2child_roles: parent2child_roles[parent]=[]
			if True: # not node in [c_r[0] for c_r in parent2child_roles[parent] if len(c_r)==2]:
				if node.startswith("salt:/"):
					row=row[:-3]
					parent2child_roles[parent].append((node,role))
				else:
					parent2child_roles[parent].append(row)

	for root in roots:
		tree=_merge2tree(parent2child_roles,node2cat, root)
		print(_tree2conll(tree))
		print()

node2cat={}
child2parent_role={}

if args.ROLES_TSV != None:
	child2parent2roles={}
	role2freq={} # we use this for disambiguation, we return the least frequent role, because there may be overlapping filters or criteria, e.g., for oacc, odat which are both included in obj
	with open(args.ROLES_TSV, "rt", errors="ignore") as input:
		sys.stderr.write(f"reading {args.ROLES_TSV}\n")
		for line in input:
			line=line.strip()
			fields=line.split("\t")
			if len(fields)>2:
				parent,child,role=fields[:3]
				if not child in child2parent2roles: child2parent2roles[child]={}
				if not parent in child2parent2roles[child]: child2parent2roles[child][parent]=[]
				if not role in child2parent2roles[child][parent]: child2parent2roles[child][parent].append(role)
				if not role in role2freq: role2freq[role]=0
				role2freq[role]+=1

	sys.stderr.write("pruning roles")
	for child in child2parent2roles:
		for parent,roles in child2parent2roles[child].items():
			cand=roles[0]
			for role in roles[1:]:
				if role2freq[role]<role2freq[cand]:
					cand=role
			child2parent_role[child]=(parent,cand)

with open(args.TREE_TSV,"rt",errors="ignore") as input:
	sys.stderr.write(f"reading {args.TREE_TSV}\n")
	for line in input:
		line=line.strip()
		fields=line.split("\t")
		if len(fields)>2:
			parent,cat,child=fields[:3]
			node2cat[parent]=cat
			if not child in child2parent_role: 
				# overridden by labelled edges
				child2parent_role[child]=(parent,"_")


with open(args.TOKENS_CONLL, "rt",errors="ignore") as input:
	buffer=[]

	for line in input:
		line=line.rstrip()

		if line.strip().startswith("#") or not "\t" in line:
			print(line)
			continue

		if line=="":
			if len(buffer)>0:
				try:
					spellout(buffer)
				except Exception:
					traceback.print_exc()
					sys.stderr.write("while processing\n")
					sys.stderr.write("\t"+"\t\n".join([ "\t".join(row) for row in buffer])+"\n")
					sys.stderr.flush()	
				print()
				buffer=[]
			continue

		fields=line.split("\t")
		orig_id=fields[-1]
		while orig_id in child2parent_role:
			parent,role=child2parent_role[orig_id]
			fields.append(role)
			fields.append(parent)
			fields.append(node2cat[parent])
			orig_id=parent

		if len(buffer)>0 and fields[-1]!=buffer[-1][-1]: # different root
			try:
					spellout(buffer)
			except Exception:
					traceback.print_exc()
					sys.stderr.write("while processing\n")
					sys.stderr.write("\n".join([ "\t".join(row) for row in buffer])+"\n")
					sys.stderr.flush()	
			buffer=[]
			print()

		buffer.append(fields)

	if len(buffer)>0:
		spellout(buffer)
		print()


