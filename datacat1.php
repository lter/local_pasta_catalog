<?php
$DEBUG=0;

# query parameters
$defType="edismax";
$queryText="Gastil";
$scopeSearch=array("-scope:ecotrends","-scope:lter-landsat*");
$fieldsReturned='*';
$sortList=array("score,desc","packageid,asc");
$doDebug="false";
$startRecord=0;
$returnNumRows=20;
if ($DEBUG) {
   print_r($scopeSearch);
   }

$queryString="defType=".$defType;
if (strlen($queryText) > 0){
    $queryString=$queryString."&q=".$queryText;
    }
    foreach ($scopeSearch as $scope){
        $queryString=$queryString."&fq=".$scope;
	}
    if (strlen($fieldsReturned) > 0){
	    $queryString=$queryString."&fl=".$fieldsReturned;
	    }
    foreach ($sortList as $sort){
     	    $queryString=$queryString."&sort=".$sort;
    }
    if (strlen($doDebug) > 0){
        $queryString=$queryString."&debug=".$doDebug;
	}
    if ($startRecord > 0){
        $queryString=$queryString."&start=".strval($startRecord);
	}
    if ($returnNumRows > 0){
        $queryString=$queryString."&rows=".strval($returnNumRows);
	}

if ($DEBUG) {echo($queryString);}
# Now execute the query and return the results
$ch= curl_init("https://pasta.lternet.edu/package/search/eml?".$queryString);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HEADER, false);
$result1=curl_exec($ch);
if ($DEBUG){print($result1);}
#file_put_contents("tmp/resultset1.xml",$result1);

# Process the XML to produce output using a stylesheet
// Load the XML source
$xml = new DOMDocument;
$xml->loadXML($result1);

$xsl = new DOMDocument;
$xsl->load('resultset2catalog.xsl');

// Configure the transformer
$proc = new XSLTProcessor;
$proc->importStyleSheet($xsl); // attach the xsl rules

echo $proc->transformToXML($xml);
curl_close($ch);

?>