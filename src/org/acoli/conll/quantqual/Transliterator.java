package org.acoli.conll.quantqual;

import java.io.*;
import java.util.*;
import java.util.regex.Pattern;

/** read tsv dict from arg, create transliteration rules:
	(1) baseline rules: positional 1:1 correspondence
	(2) pruning: keep the most frequent per src character
	(3) analyze mismatches to derive contextualized n:m matches
	
	apply these to the input as read from stdin
*/
public class Transliterator {
	
	protected final Hashtable<String,Hashtable<String,Integer>> word2word2freq;
	protected final Hashtable<String,Hashtable<String, Integer>> s2t2freq;
	protected final Vector<String> sSorted = new Vector<String>();
	protected final static boolean DEBUG = false;
	protected final boolean full;
	protected final boolean keepCase;
	
	@SuppressWarnings("serial")
	protected final Map<String, String> charMap = new HashMap<String, String>(){{
		put("~", ""); 
		put("<", ""); 
		put(">", ""); 
		put("-", ""); 
		put("!", ""); 
		put("?", ""); 
		put("/", ""); 
		put(".", ""); 
		put("(", ""); 
		put(")", ""); 
		put("[", ""); 
		put("]", ""); 
		put("+", ""); 
		put("≈", ""); 
		put("â", "a"); 
		put("å", "a"); 
		put("ä", "a"); 
		put("ā", "a"); 
		put("æ", "a"); 
		put("ǣ", "a"); 
		put("ð", "d"); 
		put("É", "E"); 
		put("è", "e"); 
		put("ê", "e"); 
		put("ë", "e"); 
		put("ē", "e"); 
		put("Ē", "E"); 
		put("î", "i"); 
		put("ī", "i"); 
		put("ô", "o"); 
		put("ö", "o"); 
		put("ō", "o"); 
		put("œ", "a"); 
		put("û", "u"); 
		put("ü", "u"); 
		put("ū", "u");
	}};

	/** depending on configuration, return a simplified string */
	protected String normalize(String s) {
		s=s.trim();
		//s=Pattern.quote(s);
		if(!full) {
			// remove diacritics			
			// remove non-A-Z (plus selected special characters, @TODO: to be extended)
		    for (Map.Entry<String, String> c : charMap.entrySet()) {
		        s = s.replaceAll(Pattern.quote(c.getKey()), c.getValue());
		    }
		}
		
		if(!keepCase) 
			s=s.toLowerCase();
		
		return s;
	}
	
	public Transliterator(Hashtable<String,Hashtable<String, Integer>> word2word2freq, boolean full, boolean keepCase) {
		this.full = full;
		this.keepCase = keepCase;
		s2t2freq = new  Hashtable<String,Hashtable<String, Integer>>();
		
		// (0) preprocessing: lowercase and accent removal in word2word2freq
		for(String src : new HashSet<String>(word2word2freq.keySet())) {
			String s = normalize(src);
			if(!s.equals(src)) {
				if(!s.equals("")) {
					if(word2word2freq.get(s)==null)
						word2word2freq.put(s, new Hashtable<String,Integer>());
					for(String tgt : word2word2freq.get(src).keySet()) {
						if(word2word2freq.get(s).get(tgt)==null)
							word2word2freq.get(s).put(tgt, 0);
						word2word2freq.get(s).put(tgt, word2word2freq.get(s).get(tgt));
					}
				}
				word2word2freq.remove(src);	
			}
		}
		
		this.word2word2freq = word2word2freq;
		
		// (1) baseline transliteration
		System.err.print("infer 1:1 replacements ..");
		for(String src : word2word2freq.keySet()) 
		  for(String tgt: word2word2freq.get(src).keySet()) {
			// System.err.println(src+" <-> "+tgt);
			for(int i = 0; i<src.length(); i++) {
				int j = Math.min(((i*tgt.length())/src.length()), tgt.length()-1);
				String s = src.substring(i,i+1);
				String t = tgt.substring(j,j+1);
				// System.err.println("\t"+s+" -> "+t);
				if(s2t2freq.get(s)==null) s2t2freq.put(s, new Hashtable<String,Integer>());
				if(s2t2freq.get(s).get(t)==null) s2t2freq.get(s).put(t,0);
				s2t2freq.get(s).put(t,s2t2freq.get(s).get(t)+word2word2freq.get(src).get(tgt));
			}
		}
		System.err.print(".");
		
		// (2) prune baseline transliteration rules
		for(String s : s2t2freq.keySet()) {
			String t = null;
			int freq = -1;
			for(String t2 : s2t2freq.get(s).keySet()) 
				if(s2t2freq.get(s).get(t2)>freq) {
					t = t2;
					freq = s2t2freq.get(s).get(t2);
				}
			s2t2freq.get(s).clear();
			s2t2freq.get(s).put(t,freq);
			// System.err.println(s+" => "+t+"\t"+freq);
		} // result looks ok except unicode issues

		this.sortKeys();
		System.err.println(". ok ["+s2t2freq.keySet().size()+" rules]");
		int rules = 0;
		
		while(rules<s2t2freq.keySet().size()) { // i.e., until no more rules inferred
			rules = s2t2freq.keySet().size();
		
			// (3) apply transliteration rules, learn contextualized rules, also store in s2t2freq
			System.err.print("infer n:m replacements ..");
			Transliterator transliterator = this;
	
			for(Map.Entry<String, Hashtable<String,Integer>> srcEntry : word2word2freq.entrySet()) 
			 // if(!normalize(srcEntry.getKey()).equals(""))
			  for(Map.Entry<String,Integer> tgtEntry: srcEntry.getValue().entrySet()) {
				String src=srcEntry.getKey();
				String tgt=tgtEntry.getKey();
				int freq = tgtEntry.getValue();
				//System.err.println(src+" "+tgt+" "+word2word2freq.get(src));
				String tgtHypo = transliterator.transliterate(src);
				/*= "";
				for(int i = 0; i<src.length(); i++) {
					String s = src.substring(i,i+1);
					String tHypo = s2t2freq.get(s).keys().nextElement();
					if(tHypo==null)
						tHypo=s;
					tgtHypo=tgtHypo+tHypo;
				} */
				if(!tgtHypo.equals(tgt)) {	// contextualizedRule: one char back and forth, learned by eliminating correctly predicted characters from left and right
					if(DEBUG) System.err.println(src+" => "+tgtHypo+" <> "+tgt);
					int left = 0;
					int right = 0;
					while(left < tgtHypo.length()-1 && left < tgt.length()-1 && tgtHypo.substring(left,left+1).equals(tgt.substring(left,left+1)))
						left++;
					while(tgtHypo.length()-right > 0 && tgt.length()-right > 0 && 
						tgtHypo.substring(tgtHypo.length()-right-1,tgtHypo.length()-right).equals(tgt.substring(tgt.length()-right-1,tgt.length()-right)))
						right++;
					
					if(right>0 && src.length()-right>0) { 
						String leftContext = " ";
						if(left>0 && left<=src.length()) leftContext=src.substring(left-1,left);
	
						String rightContext = " ";
						if(right>0) rightContext=src.substring(src.length()-right,src.length()-right+1);
	
						tgt=tgt.substring(0,tgt.length()-right);
						src=src.substring(0,src.length()-right);
	
						if(left>0 && left<src.length()-1 && left<tgt.length()-1) {
							tgt=tgt.substring(left,tgt.length());
							src=src.substring(left,src.length());
						
							String src1=leftContext+"]"+src+"["+rightContext;
						
							if(s2t2freq.get(src1)==null) s2t2freq.put(src1,new Hashtable<String,Integer>());
							if(s2t2freq.get(src1).get(tgt)==null) s2t2freq.get(src1).put(tgt,0);
							s2t2freq.get(src1).put(tgt,s2t2freq.get(src1).get(tgt)+freq);
							
							// these were *much* worse:
							/* src1=leftContext+"]"+src;
							if(s2t2freq.get(src1)==null) s2t2freq.put(src1,new Hashtable<String,Integer>());
							if(s2t2freq.get(src1).get(tgt)==null) s2t2freq.get(src1).put(tgt,0);
							s2t2freq.get(src1).put(tgt,s2t2freq.get(src1).get(tgt)+freq);
	
							src1=src+"["+rightContext;
							if(s2t2freq.get(src1)==null) s2t2freq.put(src1,new Hashtable<String,Integer>());
							if(s2t2freq.get(src1).get(tgt)==null) s2t2freq.get(src1).put(tgt,0);
							s2t2freq.get(src1).put(tgt,s2t2freq.get(src1).get(tgt)+freq);
							*/ 
							
						}
					}
				}
			}
			System.err.print(".");
			
			// (4) prune transliteration rules
			for(String s : new HashSet<String>(s2t2freq.keySet())) {
				String t = null;
				int freq = -1;
				for(String t2 : s2t2freq.get(s).keySet()) 
					if(s2t2freq.get(s).get(t2)>freq) {
						t = t2;
						freq = s2t2freq.get(s).get(t2);
					}
				s2t2freq.remove(s);
				if(freq>2 && t.length()<6) {
					s2t2freq.put(s,new Hashtable<String,Integer>());
					s2t2freq.get(s).put(t,freq);
					if(DEBUG) System.err.println(s+" => "+t+"\t"+freq);
				}
			}
			System.err.println(". ok ["+s2t2freq.keySet().size()+" rules]");		
	
			sortKeys();
		}
	}
	

	/** sort s2t2freq for length, start with longest<br/>MUST be called before doing transliterate, should be called from constructor only */
	protected void sortKeys() {
		sSorted.clear();
		for(String s : s2t2freq.keySet()) {
			for(int i = 0; i<sSorted.size() && !sSorted.contains(s); i++)
				if(s.length()>=sSorted.get(i).length()) sSorted.insertElementAt(s,i);
			if(!sSorted.contains(s)) sSorted.add(s);
		}
	}

	/** this transliteration is not particularly good ..., in DEBUG mode, direct lookup is disabled */
	public String transliterate(String src) {
		
		src=this.normalize(src);
		if(src.equals("")) return src;
		
		// direct lookup: we return all translations in alphabetical order
		if(this.word2word2freq.get(src)!=null && !DEBUG) {
			return (new TreeSet<String>(word2word2freq.get(src).keySet())).toString(); //.replaceFirst("^\\[", "").replaceFirst("\\]$", "");
			// return the most frequent
			/* String result = src;
			int f = 0;
			for(Map.Entry<String, Integer> e : word2word2freq.get(src).entrySet())
				if(e.getValue()> f || (e.getValue()==f && e.getKey().compareTo(result)>0)) {
					result=e.getKey();
					f=e.getValue();
				}
			return result; */
		}
		
		// otherwise: transliterate
		if(DEBUG) System.err.println(sSorted);
		if(DEBUG) System.err.println("transliterate("+src+")");
		Vector<String> origSeg = new Vector<String>();
		Vector<String> tgtSeg = new Vector<String>();
		origSeg.add(" ");
		origSeg.add(src);
		origSeg.add(" ");
		tgtSeg.add("");
		tgtSeg.add(null);
		tgtSeg.add("");
				
		// start with longest
		if(DEBUG) System.err.println(sSorted);
		for(String s : sSorted) {
			if(DEBUG) System.err.println("test "+s);
			String left = "";
			if(s.contains("]")) left = s.replaceFirst("\\].*","\\]");
			String right = "";
			if(s.contains("[")) right = s.replaceFirst(".*\\[","\\[");
			s=s.replaceFirst(".*\\]","").replaceFirst("\\[.*","");
			if(origSeg.toString().toLowerCase().contains(s) && s2t2freq.get(left+s+right)!=null) {
				for(int i = 0; i<origSeg.size(); i++)
					if(tgtSeg.get(i)==null) {
						if(origSeg.get(i).contains(s)) {
				
							String tgt = s2t2freq.get(left+s+right).keys().nextElement(); // get most freq target (should be unique)
							for(String t : s2t2freq.get(left+s+right).keySet())
								if(s2t2freq.get(left+s+right).get(t) > s2t2freq.get(left+s+right).get(tgt)) tgt = t;
								
							boolean leftMatch = origSeg.get(i).startsWith(s) && (left.equals("") || (i>0 && origSeg.get(i-1).endsWith(left.replaceFirst("[\\[\\]]", ""))));
							boolean rightMatch = origSeg.get(i).endsWith(s) && (right.equals("") || (i<origSeg.size()-1 && origSeg.get(i+1).startsWith(right.replaceFirst("[\\[\\]]", ""))));
							boolean inMatch = origSeg.get(i).contains((left+s+right).replaceAll("[\\[\\]]", ""));
							boolean fullMatch = origSeg.get(i).equals(s) && leftMatch && rightMatch;

							if(DEBUG)
							  if(leftMatch || rightMatch || inMatch || fullMatch) {
								System.err.println(origSeg+" => "+tgtSeg+"\n"+
									"  "+origSeg.get(i)+" contains \""+left+s+right+"\" => "+s2t2freq.get(left+s+right).keySet()+
									" f:"+fullMatch+" l:"+leftMatch+" r:"+rightMatch+" i:"+inMatch);
							}
							
							// System.err.println("  l:"+leftMatch+" r:"+rightMatch);
							
							if(fullMatch) {
								tgtSeg.removeElementAt(i);
								tgtSeg.insertElementAt(tgt,i);
							} else if(leftMatch) {
								origSeg.insertElementAt(s,i);
								origSeg.insertElementAt(origSeg.get(i+1).replaceFirst("^"+s,""),i+1);
								origSeg.removeElementAt(i+2);
								tgtSeg.insertElementAt(tgt,i);
							} else if(rightMatch) {
								String orig = origSeg.get(i);
								//origSeg.insertElementAt(orig.replaceFirst(s+"$",""),i);
								origSeg.insertElementAt(orig.substring(0,orig.length()-s.length()),i);
								origSeg.insertElementAt(s,i+1);
								origSeg.removeElementAt(i+2);
								tgtSeg.insertElementAt(tgt,i+1);
								i=i-1;
							} else if(inMatch) { // in between: check context
								String orig = origSeg.get(i);
								String pre = orig.replaceFirst(left.replaceFirst("[\\[\\]]", "")+Pattern.quote(s)+right.replaceFirst("[\\[\\]]", "")+".*$",left.replaceFirst("[\\[\\]]", ""));
								// String post = orig.replaceFirst("^.*"+left+s+right,right);
								String post = orig.substring(pre.length()+s.length(), orig.length());
								origSeg.insertElementAt(pre,i);
								origSeg.insertElementAt(s,i+1);
								origSeg.insertElementAt(post,i+2);
								origSeg.removeElementAt(i+3);
								tgtSeg.insertElementAt(tgt,i+1);
								tgtSeg.insertElementAt(null,i+2);
								i=i-1;
							}
						}
					}
			}
		}
		
		if(DEBUG) {
			System.err.println(origSeg);
			System.err.println(tgtSeg);
		}
		
		String result = "";
		for(int i = 0; i<tgtSeg.size(); i++) {
			if(tgtSeg.get(i)!=null) {
				result=result+tgtSeg.get(i);
			} else result = result+origSeg.get(i);
		}
		
		return result.trim();
		
		/*= "";
			for(int i = 0; i<src.length(); i++) {
				String s = src.substring(i,i+1);
				String tHypo = s2t2freq.get(s).keys().nextElement();
				if(tHypo==null)
					tHypo=s;
				tgtHypo=tgtHypo+tHypo;
			} */
	}
	
	public static void main(String[] argv) throws Exception {
		
		int src = 0;
		int tgt = 1;
		int word = 0;
		boolean full = false;
		boolean keepCase = false;
		String encoding = "UTF8";
		
		System.err.println("synopsis: Transliterator DICT.TSV [-full] [-keepCase] [-encoding \"ENCODING\"] [ [ [ COL_SRC ] COL_TGT] COL_WORD ]\n"
				+ "  DICT.TSV            dictionary in tsv format\n"
				+ "  -full               keep accents and [^a-zA-Z] when comparing WORD and SRC (default: ignore accents and [^a-zA-z]]\n"
				+ "  -keepCase           keep case when comparing WORD and SRC (default: lowercase)\n"
				+ "  -encoding \"UTF8\"  encoding for both input files and output - default is UTF8\n"
				+ "  COL_SRC             source column in DICT.TSV (first column = 1), by default "+(src+1)+"\n"
				+ "  COL_TGT             target column in DICT.TSV (first column = 1), by default "+(tgt+1)+"\n"
				+ "  COL_WORD            column in the data file that contains the forms that are to be normalized, by default "+(word+1)+"\n"
				+ "read CoNLL file from stdin, with normalize entries from COL_WORD according to DICT.TSV, add this as new column\n"
				+ "write to stdout");		
		
		try {
			word = Integer.parseInt(argv[argv.length-1]) - 1; 
			tgt = Integer.parseInt(argv[argv.length-2]) -1;
			src = Integer.parseInt(argv[argv.length-3]) -1;
		} catch (Exception e) {}
		
		full = (Arrays.asList(argv).toString().toLowerCase().contains("-full"));
		keepCase = (Arrays.asList(argv).toString().toLowerCase().contains("-keepcase"));
		if (Arrays.asList(argv).toString().toLowerCase().contains("-encoding")) {
			encoding = (Arrays.asList(argv).toString().toLowerCase().replaceAll(".*-encoding, ([^\\], ]*).*", "$1"));
			encoding = encoding.toUpperCase();
		}
		
		System.err.print("run Transliterator "+argv[0]+" ");
		if(full) System.err.print("-full ");
		if(keepCase) System.err.print("-keepCase ");
		System.err.println((src+1)+" "+(tgt+1)+" "+(word+1));
		
		BufferedReader in = new BufferedReader(new InputStreamReader(new FileInputStream(argv[0]), encoding));
		
		Hashtable<String,Hashtable<String,Integer>> src2tgt2freq = new Hashtable<String,Hashtable<String,Integer>>();
		//Hashtable<String,Hashtable<String,Integer>> s2t2freq = new Hashtable<String,Hashtable<String,Integer>>();
		
		// (0) initialize
		System.err.print("initialize ..");
		int total = 0;
		for(String line = ""; line!=null; line=in.readLine()) {
			String[] fields = line.replaceFirst("^#.*","").replaceFirst("([^\\\\])#.*", "$1").split("\t");
			if(fields.length>Math.max(src, tgt)) {
				String s = fields[src].trim();
				String t = fields[tgt].trim();
				if(!s.trim().equals("_") && !s.trim().equals("") && !t.trim().equals("_") && !t.trim().equals("")) {	// skip empty entries
					if(src2tgt2freq.get(s)==null) src2tgt2freq.put(s, new Hashtable<String,Integer>());
					if(src2tgt2freq.get(s).get(t)==null) src2tgt2freq.get(s).put(t, 0);
					src2tgt2freq.get(s).put(t,src2tgt2freq.get(s).get(t)+1);
					total++;
					if(total % 1000 == 0) System.err.print(".");
				}
			}
		}
		System.err.println(". ok ["+total+" total]");
		
		// create Transliterator
		Transliterator me = new Transliterator(src2tgt2freq, full, keepCase);
		
		// (5) test transliteration 
		in = new BufferedReader(new InputStreamReader(System.in, encoding));
		//in = new BufferedReader(new InputStreamReader(System.in));
		PrintStream out = new PrintStream(System.out, true, encoding);
		for(String line = in.readLine(); line!=null; line=in.readLine()) {
			if(line.startsWith("#")) {
				out.println(line);
			} else {
				String comment = "";
				if(line.matches(".*[^\\\\]#.*")) {
					comment = line.replaceFirst(".*[^\\\\]#","#");
					line=line.replaceFirst("([^\\\\])#.*", "$1");
				}
				String[] fields = line.split("\t");
				if(fields.length<=word) {
					out.println(line+comment);
				} else {
					out.println(line+"\t"+me.transliterate(fields[word].trim()));
				}
			}
		}
	}
}
