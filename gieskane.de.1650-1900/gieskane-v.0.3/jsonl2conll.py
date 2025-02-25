import sys,os,re,json,argparse
args=argparse.ArgumentParser(description="read JSON-L from stdin, write CoNLL; note that we don't reorder, so we expect things to be presented in reading order")
args.add_argument("files", nargs="*",type=str, help="JSON-L files to read from, alternatively, from stdin", default=[])
args.add_argument("-c","--out_cols", nargs="*", type=str, help="output columns, as identified by their column label; HIGHLY RECOMMENDED: if omitted, we return columns in the order the respective feature is first observed, so, there may be different column orders for different corpora",default=[])
args.add_argument("-c","--out_cols", nargs="*", type=str, help="output columns, as identified by their column label; HIGHLY RECOMMENDED: if omitted, we return columns in the order the respective feature is first observed, so, there may be different column orders for different corpora",default=[])
args=args.parse_args()

if len(args.files)==0: 
	args.files=[sys.stdin]
	sys.stderr.write("reading from stdin\n")

static_cols=(len(args.out_cols)>0)

if static_cols:
	print("# "+"\t".join(args.out_cols))
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
			if not static_cols:
				for k in anno:
					if not k in args.out_cols:
						args.out_cols.append(k)
			result=[ anno[k] if k in anno else "_" for k in args.out_cols ]
			print("\t".join(result))

	file.close()
