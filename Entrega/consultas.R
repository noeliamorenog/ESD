library(SPARQL)
endpoint <- "http://34.141.128.150:9999/blazegraph/namespace/Daltonism_Types/sparql"

# 1. ¿Qué genes están asociados a cada tipo de Daltonismo?

query1 <- "
PREFIX rdfs : <http ://www .w3.org / 2000 /01/rdf - schema #>
PREFIX rdf : <https ://www .w3.org / 1999 /02/22-rdf -syntax -ns#>
PREFIX ncit : <https :// ncit .nci .nih .gov / ncitbrowser /#>
PREFIX ensembl : <http ://www . ensembl .org /id/>
PREFIX obo : <http :// purl . obolibrary .org /obo />
PREFIX specie : <https :// cancerdata .org / specie />
SELECT DISTINCT ? gene ? geneLabel ? protein ? proteinLabel
WHERE {
? gene rdf: type ncit : C16612 ;
rdfs : label ? geneLabel .
OPTIONAL {
? protein rdf: type ncit : C17021 ;
rdfs : label ? proteinLabel ;
obo :SIO_ 010079 ? gene .
}
? gene rdf: type specie : Homo _ Sapiens .
}
"
qd1 <- SPARQL( endpoint , query1 )
View(qd1$results)

query2 <- "
PREFIX rdf : <https ://www .w3.org / 1999 /02/22-rdf -syntax -ns#>
PREFIX rdfs : <http ://www .w3.org / 2000 /01/rdf - schema #>
PREFIX specie : <https :// cancerdata .org / specie />
PREFIX obo : <http :// purl . obolibrary .org /obo />
PREFIX ncit : <https :// ncit .nci .nih .gov / ncitbrowser /#>
PREFIX cancer : <https :// cancerdata .org / types />
PREFIX afo : <http :// purl . allotrope .org / ontologies / property /#>
SELECT ? humanGeneLabel ? humanChromosome ? humanProteinLabel ?
mouseProteinLabel ? humanGeneComment
WHERE {
? humanGene rdf: type specie : Homo _ Sapiens ;
rdfs : label ? humanGeneLabel ;
ncit : C28708 ? mouseGene ;
obo : PATO _ 0002261 ? humanChromosomeUri ;
obo :SIO_ 010078 ? humanProteinUri ;
rdfs : comment ? humanGeneComment .
? mouseGene rdf: type specie :Mus_ musculus ;
rdfs : label ? mouseGeneLabel ;
obo :SIO_ 010078 ? mouseProteinUri .
? protein rdf: type ncit : C17021 ;
obo :SIO_ 010079 ? humanGene .
BIND ( REPLACE (STR (? humanChromosomeUri ), ’https :// cancerdata .org /
chromosome / ’, ’’) AS ? humanChromosome )
BIND ( REPLACE (STR (? humanProteinUri ), ’http ://www . uniprot .org / uniprot / ’,
’’) AS ? humanProteinLabel )
BIND ( REPLACE (STR (? mouseProteinUri ), ’http ://www . uniprot .org / uniprot / ’,
’’) AS ? mouseProteinLabel )
}
"
qd2 <- SPARQL( endpoint , query2 )
View(qd2$results )

query3 <- "
PREFIX rdf : <https ://www .w3.org / 1999 /02/22-rdf -syntax -ns#>
PREFIX ncit : <https :// ncit .nci .nih .gov / ncitbrowser /#>
PREFIX rdfs : <http ://www .w3.org / 2000 /01/rdf - schema #>
PREFIX cancer : <https :// cancerdata .org / types />
PREFIX low _exp : <https :// cancerdata .org /low _ expexpression />
PREFIX high _exp : <https :// cancerdata .org / high _ expexpression />
PREFIX owl : <http ://www .w3.org / 2002 /07/owl #>
SELECT ? proteinName ( REPLACE (STR (? uniProtURI ), ’http ://www . uniprot .org /
uniprot / ’, ’’) AS ? uniProtID ) ? cancerType ? proteinLength ?
expressionLevel
WHERE {
{
? cancer rdf: type ncit : C9305 ;
rdfs : label ? cancerType ;
low_exp:low ? protein .
? protein rdf: type ncit : C17021 ;
rdfs : label ? proteinName ;
ncit : C25334 ? proteinLength ;
owl : sameAs ? uniProtURI .
BIND (’Low ’ AS ? expressionLevel )
}
UNION
{
? cancer rdf: type ncit : C9305 ;
rdfs : label ? cancerType ;
high _ exp: high ? protein .
? protein rdf: type ncit : C17021 ;
rdfs : label ? proteinName ;
ncit : C25334 ? proteinLength ;
owl : sameAs ? uniProtURI .
BIND (’High ’ AS ? expressionLevel )
}
}
ORDER BY xsd: integer (? proteinLength )
"
qd3 <- SPARQL( endpoint , query3 )
View(qd3$results )

query4 <- "
PREFIX rdf : <https ://www .w3.org / 1999 /02/22-rdf -syntax -ns#>
PREFIX ncit : <https :// ncit .nci .nih .gov / ncitbrowser /#>
PREFIX rdfs : <http ://www .w3.org / 2000 /01/rdf - schema #>
PREFIX dcterms : <http :// purl .org /dc/ terms />
PREFIX publi : <https :// cancerdata .org / pulication />
PREFIX cancer : <https :// cancerdata .org / types />
PREFIX owl : <http ://www .w3.org / 2002 /07/owl #>
SELECT ? pubmedID ? date ? title
WHERE {
? cancer rdf: type ncit : C9305 ;
rdfs : label ? cancerLabel ;
dcterms :ref ? publication .
FILTER (? cancerLabel = ’Colorectal Cancer ’)
? publication rdf: class ncit : C48471 ;
owl : sameAs ? pubURL ;
dcterms : title ? title ;
dcterms : date ? date .
BIND ( REPLACE (STR (? pubURL ), ’https :// pubmed . ncbi .nlm .nih .gov / ’, ’’) AS ?
pubmedID )
}
ORDER BY DESC (? date )
"
qd4 <- SPARQL( endpoint , query4 )
View(qd4$results )

query5 <- "
PREFIX rdf : <https ://www .w3.org / 1999 /02/22-rdf -syntax -ns#>
PREFIX rdfs : <http ://www .w3.org / 2000 /01/rdf - schema #>
PREFIX ncit : <https :// ncit .nci .nih .gov / ncitbrowser /#>
PREFIX obo : <http :// purl . obolibrary .org /obo />
PREFIX afo : <http :// purl . allotrope .org / ontologies / property /#>
PREFIX cancer : <https :// cancerdata .org / types />
SELECT ? proteinLabel ? geneLabel ? orthologGeneLabel ? cancerType ?
maxProteinLength ? proteinComment
WHERE {
{
SELECT ? protein (MAX (xsd : integer (? length )) AS ? maxProteinLength )
WHERE {
? protein ncit : C25334 ? length .
}
GROUP BY ? protein
}
? protein rdfs : label ? proteinLabel .
? protein rdfs : comment ? proteinComment .
? protein obo:SIO_ 010079 ? gene .
? gene rdfs : label ? geneLabel .
? gene ncit : C28708 ? orthologGene .
? orthologGene rdfs : label ? orthologGeneLabel .
? cancer afo:AFX_ 0002745 ? protein ;
rdfs : label ? cancerType .
}
ORDER BY DESC (? maxProteinLength )
LIMIT 1
"
qd5 <- SPARQL( endpoint , query5 )
View(qd5$results )