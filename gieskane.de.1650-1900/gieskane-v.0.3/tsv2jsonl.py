import sys,os,re,json,argparse

args=argparse.ArgumentParser(""" read TSV from stdin or files, write JSONL for non-null elements
	assume fist line contains header """)
args.add_argument("files", type=str, nargs="*", help="TSV files, if empty, read from stdin", default=[])
args.add_argument("-nh", "--no_header", action="store_true", help="use COL1, etc. for column labels; by default, we assume that the first row contains header labels")
args.add_argument("-g", "--group_by", type=str, help="attribute to be used for GROUP BY, e.g., 2_id for grouping by tokens in Gieskane, if unspecified, don't aggregate; Note that we require elements to be grouped by to occur one after another, otherwise, we split; if doing group by, we concatenate multiple different values", default=None)
args.add_argument("-s", "--skip_cols", type=str, nargs="*", help="skip columns, identified by the their header column, and separated by space, e.g., -s 1_id", default=[])
args=args.parse_args()

if len(args.files)==0:
	sys.stderr.write("reading from stdin\n")
	args.files=[sys.stdin]

for file in args.files:
	if isinstance(file,str):
		sys.write(f"reading from {file}\n")
		file=open(file,"rt",errors="ignore")
	header=None
	mydict={}
	for line in file:
		line=line.strip()
		if len(line)>0:
			if header==None:
				header=[]
				if not args.no_header: 
					header=line.strip().split("\t")
					continue
			fields=line.split("\t")
			while len(header)<len(fields):
				header.append(f"COL{len(header)}")
			dict_addenda={ k:v for k,v in zip(header,fields) if not v in ["","NULL","'NULL'", '"NULL"', None,"_"] and not k in args.skip_cols}
			if len(mydict)>0:
				if args.group_by==None or not args.group_by in mydict or not args.group_by in dict_addenda or mydict[args.group_by]!=dict_addenda[args.group_by]:
					json.dump(mydict,sys.stdout)
					print()
					mydict={}
			for k,v in dict_addenda.items():
				if not k in mydict: 
					mydict[k]=v
				elif not v in mydict[k].split("|"):
					mydict[k]+=f"|{v}"
	if len(mydict)>0:
		json.dump(mydict,sys.stdout)
		print()
		mydict={}

	print()
	file.close()


