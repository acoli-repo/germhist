#!/bin/bash
DB=http://localhost:9999/bigdata/sparql;

echo synopsis: $0 WN GN [DB] 1>&2
echo '  WN WordNet 3.1, RDF dump in local file, cf. http://wordnet-rdf.princeton.edu/wn31.nt.gz' 1>&2
echo '  GN German WN 3.1 lexicalizations from GermaNet, RDF dump in local file' 1>&2
echo '  DB sparql end point (by default '$DB')' 1>&2
echo clear DB, load WN and GN, retrieve animacy as CSV 1>&2

if echo $3 | egrep '.' > /dev/null; then
	DB=$3;
fi;

WN=$1;
GN=$2;

if echo $OSTYPE | egrep 'cygwin' >& /dev/null; then
	WN='file:/'`cygpath -wa $WN;`
	WN=`echo $WN | perl -pe 's/\\\\/\//g;'`
	GN='file:/'`cygpath -wa $GN;`
	GN=`echo $GN | perl -pe 's/\\\\/\//g;'`
else 
	WN='file://'`realpath $WN`;
	GN='file://'`realpath $GN`;
fi;

echo running $0 $WN $GN $DB 1>&2;

# init GermaNet, incl. linking to PWN31
echo 1>&2
echo "initialize GermaNet and link to WordNet 3.1" 1>&2;
curl -X POST $DB --data-urlencode 'update=
PREFIX wno: <http://wordnet-rdf.princeton.edu/ontology#>
PREFIX wn: <http://wordnet-rdf.princeton.edu/wn31/>

# initialize GN
	DROP ALL;
	LOAD <'$GN'>;

# link GN to PWN3.1

	CREATE SILENT GRAPH <https://github.com/globalwordnet/ili>;

	# # LOAD <https://raw.githubusercontent.com/globalwordnet/ili/master/ili-map-wn30.ttl> INTO GRAPH <https://github.com/globalwordnet/ili>;
	LOAD <file:/C:/Users/chiarcos/Desktop/wordnet/animacy/wordnet-rdf/ili-map-wn30.ttl> INTO GRAPH <https://github.com/globalwordnet/ili>; 
	
	# map wn30 to ili
	DELETE {
		?a ?b ?wn30. ?wn30 ?c ?d.
	} INSERT {
		?a ?b ?ili. ?ili ?c ?d.
	} WHERE {
		GRAPH <https://github.com/globalwordnet/ili> {
			?ili owl:sameAs ?wn30.
			FILTER(contains(str(?ili),"/ili/"))
		}
		{ ?a ?b ?wn30 } UNION { ?wn30 ?c ?d }
	};
	
	CLEAR GRAPH <https://github.com/globalwordnet/ili>;
	# LOAD <https://raw.githubusercontent.com/globalwordnet/ili/master/ili-map-wn31.ttl> INTO GRAPH <https://github.com/globalwordnet/ili>;
	LOAD <file:/C:/Users/chiarcos/Desktop/wordnet/animacy/wordnet-rdf/ili-map-wn31.ttl> INTO GRAPH <https://github.com/globalwordnet/ili>;
	
	# map ili to wn31
	DELETE {
		?a ?b ?ili. ?ili ?c ?d.
	} INSERT {
		?a ?b ?wn31. ?wn31 ?c ?d.
	} WHERE {
		GRAPH <https://github.com/globalwordnet/ili> {
			?ili owl:sameAs ?wn31.
		}
		{ ?a ?b ?ili } UNION { ?ili ?c ?d }
	};
	
	DROP GRAPH <https://github.com/globalwordnet/ili>;
' | w3m -T text/html | cat 1>&2;

echo 1>&2;
echo load PWN 3.1 1>&2
curl -X POST $DB --data-urlencode 'update=
PREFIX wno: <http://wordnet-rdf.princeton.edu/ontology#>
PREFIX wn: <http://wordnet-rdf.princeton.edu/wn31/>

# initialize WN
	LOAD <'$WN'>;
' | w3m -T text/html | cat 1>&2;

# animacy inference	
echo 1>&2;
echo infer animacy 1>&2
curl -X POST $DB --data-urlencode 'update=
PREFIX wno: <http://wordnet-rdf.princeton.edu/ontology#>
PREFIX wn: <http://wordnet-rdf.princeton.edu/wn31/>


# animacy inference for nouns
# mark animate classes

INSERT DATA {
	wn:100021007-n wno:animacy "inanimate".	# added
	wn:100004258-n wno:animacy "animate".
	wn:100007846-n wno:animacy "human".
	wn:109213796-n wno:animacy "human".
	wn:110398111-n wno:animacy "human".
	wn:114802595-n wno:animacy "human".
	wn:107958392-n wno:animacy "human".
	wn:107967506-n wno:animacy "human".
	wn:107983996-n wno:animacy "human".
	wn:107984596-n wno:animacy "human".
	wn:108177175-n wno:animacy "human".
	wn:108195659-n wno:animacy "human".
	wn:108197108-n wno:animacy "human".
	wn:108323595-n wno:animacy "human".
};

# propagate downwards
INSERT {
	?a wno:animacy ?animacy.
} WHERE {
	?a wno:part_of_speech wno:noun.
	FILTER(NOT EXISTS { ?a wno:animacy [] })
	?a wno:hypernym+/wno:animacy ?animacy.
};

# mark inanimates (incl. abstracts, i.e., everything else *which has a hypernym*) 
INSERT {
	?a wno:animacy "inanimate".
} WHERE {
	?a wno:part_of_speech wno:noun.
	?a wno:hypernym* wn:100003553-n .
	FILTER(NOT EXISTS{?a wno:animacy [] })
};

# disambiguation rules: inanimate > animate/human, human > animate
DELETE {
	?a wno:animacy ?other.
} INSERT {
	?a wno:animacy "inanimate".
} WHERE {
	?a wno:animacy "inanimate", ?other.
};
DELETE {
	?a wno:animacy ?other.
} INSERT {
	?a wno:animacy "human".
} WHERE {
	?a wno:animacy "human", ?other.
};

# Animacy inference for adjectives
INSERT {
	?adj wno:animacy ?animacy.
} WHERE {
	?adj wno:part_of_speech wno:adjective.
	?adj wno:also*/wno:domain_category/wno:animacy ?animacy.
};

# in case of ambiguity (for adjectives), remove animacy annotation for adjectives
INSERT {
	?adj wno:animacy ?a1, ?a2.
} WHERE {
	?adj wno:animacy ?a1, ?a2.
	FILTER(str(?a1)!=str(?s2))
};
' | w3m -T text/html | cat 1>&2;

echo 1>&2;
echo export animacy 1>&2
curl -X POST $DB --data-urlencode 'query=
PREFIX wno: <http://wordnet-rdf.princeton.edu/ontology#>
PREFIX wn: <http://wordnet-rdf.princeton.edu/wn31/>
PREFIX lemon: <http://lemon-model.net/lemon#>

SELECT DISTINCT ?form ?pos ?animacy
WHERE {
?sense wno:animacy [].
?sense wno:translation ?form.
?sense wno:part_of_speech ?p.
FILTER(lang(?form)="de")

{ SELECT ?form ?p (GROUP_CONCAT(DISTINCT(?a); separator=", ") AS ?animacy)
  WHERE {
	?sense wno:translation ?form.
	?sense wno:part_of_speech ?p.
	?sense wno:animacy ?a.
  } GROUP BY ?form ?p ORDER BY ?form ?p ?a
}

BIND(replace(str(?p),".*#","") AS ?pos)
}
' -H 'Accept:text/csv';
