package aniImpP;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AniImp {
	
	String SEP = ",";
	
	private static class Pair<F, S> {
		public final F first;
		public final S second;
		public Pair (F first, S second) {
			this.first = first;
			this.second = second;
		}
	}
	
	private static class TSVDict {
		
		private Map<String, List<Pair<String,String> > > dict = new HashMap<String, List<Pair<String, String> > >();
		
		public TSVDict() {
		}
		
		@SuppressWarnings("serial")
		public void add(String f1, String f2, String f3) {
			if (this.dict.containsKey(f1))
				this.dict.get(f1).add(new Pair<String, String>(f2, f3));
			else
				this.dict.put(f1, new ArrayList<Pair<String, String> >(){{add(new Pair<String, String>(f2, f3));}});
		}
		
		public String[] get(String key, String pos) {
			String[] result = new String[0];
			if (this.dict.containsKey(key))
				for (Pair<String, String> p: this.dict.get(key))
					if (p.first.equals("noun") && pos.startsWith("N")) // only noun animacy is checked
						if (result.length == 0) { // enable multiple entries per word
							String[] ans = p.second.split("\\|");
							String[] sav = new String[ans.length + result.length];
							System.arraycopy(result, 0, sav, 0, result.length);
							System.arraycopy(ans, result.length, sav, 0, ans.length);
							result = sav;
						} else
							result = p.second.split("\\|");
			return result;
		}
		
	}

	public static void main(String[] args) throws IOException {
		System.err.println("synopsis: AniImp [animacySrc posColumn [animacyColumns+]]\n"
				+ "\tanimacySrc the source file with the lemma pos and animacy\n"
				+ "\tposColumn the column number (which start at 0) for the POS tag\n"
				+ "\tanimacycolumns+ column numbers to be annotated (whitespace separated)\n"
				+ "\tlooks up the lemmas given in the animacycolumns in the given animacySrc\n"
				+ "\t(ignores case and looks only for nouns)");
		File animacySrc = new File(args[0]);
		int posCol = Integer.parseInt(args[1]);
		TSVDict aniDict = new AniImp.TSVDict();
		List<Integer> colNums = new ArrayList<Integer>();
		for (int i = 2; i < args.length; i++) {
			colNums.add(Integer.parseInt(args[i]));
		}
		int colMin = (int)Collections.min(colNums);
		
		
		BufferedReader tsvin = new BufferedReader(new FileReader(animacySrc));
		tsvin.readLine(); // skip first line as header
		for(String line = tsvin.readLine(); line !=null; line=tsvin.readLine()) {
			line=line.replaceAll(", ", "|");
			String[] ts = line.split(",");
			aniDict.add(ts[0].toLowerCase(), ts[1], ts[2].replaceAll("\"", ""));
		}
		
		BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
		OutputStreamWriter out = new OutputStreamWriter(System.out);
		for(String line = ""; line !=null; line=in.readLine()) {
			String newLine = line;
			String[] cols = line.split("\t");
			
			if (cols.length > colMin) {
				String animacy = "[";
				for (Integer colNum: colNums) {
					String pos = cols[posCol];
					String trans = cols[colNum];
					if (trans.startsWith("[")) { // only annotate transliterated lemmas
						trans=trans.replaceAll("\\[(.*)\\]", "$1");						
						for (String tt: trans.split(", ")) {
							String animacyEntry = String.join(", ", aniDict.get(tt.toLowerCase(), pos));
							if (!animacyEntry.isEmpty())
								animacy = animacy + animacyEntry + ", ";
						}
					}
				}
				if (animacy.endsWith(", "))
					animacy = animacy.substring(0, animacy.length() - 2) + "]";
				if (animacy.equals("[]") || animacy.equals("["))
					animacy = "-";
				newLine = newLine + "\t" + animacy;
			}
			out.write(newLine + "\n");
			out.flush();
		}
		tsvin.close();
	}

}
