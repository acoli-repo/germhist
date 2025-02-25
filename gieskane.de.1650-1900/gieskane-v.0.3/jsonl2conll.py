import sys,os,re,json,argparse,traceback
args=argparse.ArgumentParser(description="read JSON-L from stdin, write CoNLL; note that we don't reorder, so we expect things to be presented in reading order")
args.add_argument("config", type=str, help="JSONL configuration for column export, note that we only export features declared there, and that multiple features can be mapped to the same column, |-concatenated")
args.add_argument("files", nargs="*",type=str, help="JSON-L files to read from, alternatively, from stdin", default=[])
args.add_argument("-s", "--split_sentence_at", type=str, nargs="*", help="one or more regular expressions that define sentence splits; for one key and one value, separated by '=', e.g., S=$. If more than one condition are specified, we treat them as alternative criteria (disjunction)", default=[])
args.add_argument("-n", "--add_numerical_IDs", action="store_true", help="add CoNLL-style word numbers as first column; note that this is extrapolated from sentence splits and incoming lines. this may or may not match the original corpus IDs")
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

header=[c["label"] for c in config ]
if args.add_numerical_IDs:
	header=["ID"]+header

print("# "+"\t".join(header))
print()

for file in args.files:
	if isinstance(file,str):
		sys.stderr.write(f"reading from {file}\n")
		print(f"# file: {file}\n")
		file=open(file,"rt",errors="ignore")

	word_nr=0

	for line in file:
		line=line.strip()
		if len(line)>0:
			try:
				anno=json.loads(line)
			except json.decoder.JSONDecodeError:
				traceback.print_exc()
				print(line)
				continue

			result=[]
			if args.add_numerical_IDs:
				word_nr+=1
				result.append(str(word_nr))
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

			if args.split_sentence_at!=None:
				for exp in args.split_sentence_at:
					keyexp=exp.split("=")[0]
					valexp=exp.split("=")[1]
					new_sentence=False

					for key,vals in zip(header,result):
						if re.match(keyexp,key) or keyexp==key:

							for val in vals.split("|")+[vals]:
								if re.match(valexp,val) or valexp==val:
									new_sentence=True
									break
						if new_sentence==True: 
							break

					if new_sentence==True: 
						print()
						word_nr=0
						break

	file.close()
