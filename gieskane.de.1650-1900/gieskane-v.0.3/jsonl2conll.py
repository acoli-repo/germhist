import sys,os,re,json,argparse
args=argparse.ArgumentParser(description="read JSON-L from stdin, write CoNLL; note that we don't reorder, so we expect things to be presented in reading order")
args.add_argument("config", type=str, help="JSONL configuration for column export, note that we only export features declared there, and that multiple features can be mapped to the same column, |-concatenated")
args.add_argument("files", nargs="*",type=str, help="JSON-L files to read from, alternatively, from stdin", default=[])
args=args.parse_args()

config=[]
sys.stderr.write(f"reading {args.config}\n")
with open(args.config) as input:
	for line in input:
		line=line.strip()
		if not line.startswith("#") and len(line)>0:
			config.append(json.loads(line))

if len(args.files)==0: 
	args.files=[sys.stdin]
	sys.stderr.write("reading from stdin\n")

print("# "+"\t".join([c["label"] for c in config ]))
print()

for file in args.files:
	if isinstance(file,str):
		sys.stderr.write(f"reading from {file}\n")
		print(f"# file: {file}\n")
		file=open(file,"rt",errors="ignore")

	for line in file:
		line=line.strip()
		if len(line)>0:
			anno=json.loads(line)
			result=[]
			for col in config:
				add=[]
				for key in col["keys"]:
					if key in anno:
						val=anno[key]
						if not val in add: 
							add.append(val)
				add="|".join(add)
				if len(add)==0:
					add="_"
				result.append(add)
			print("\t".join(result))

	file.close()
