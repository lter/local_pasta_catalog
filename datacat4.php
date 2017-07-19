<?php
$DEBUG=0;

# Sanitize inputs from web form (security first!)
$queryText=filter_input(INPUT_GET,'searchString',FILTER_SANITIZE_STRING);
$queryScope=filter_input(INPUT_GET,'scope',FILTER_SANITIZE_STRING);
$returnForm=filter_input(INPUT_GET,'form',FILTER_SANITIZE_STRING);

# Build a web service query string
# First define variables that hold the parts of the query
$defType="edismax";
if ($queryScope == ""){
   	# if no queryScope specified, use the default 
   	$scopeSearch=array("-scope:ecotrends","-scope:lter-landsat*");
}else{
	# otherwise add the queryScope from the form
	$scopeSearch=array("+scope:".$queryScope,"-scope:ecotrends","-scope:lter-landsat*");
}
$fieldsReturned='packageid,doi,title,authors,begindate,enddate,keywords,keyword,author';
$sortList=array("score,desc","packageid,asc");
$doDebug=false;
$startRecord=0;
$returnNumRows=100;
if ($DEBUG) {
   print_r($scopeSearch);
   }

# Append non-empty query elements into a single string
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
# set CURL options
$ch= curl_init("https://pasta.lternet.edu/package/search/eml?".$queryString);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HEADER, false);
# execute CURL and get the results
$result1=curl_exec($ch);
if ($DEBUG){print($result1);}

# Process the XML to produce output using a stylesheet

# Set up some error handling for ill-formed XML
function HandleXmlError($errno, $errstr, $errfile, $errline)
{
    if ($errno==E_WARNING && (substr_count($errstr,"DOMDocument::loadXML()")>0))
        {
            throw new DOMException($errstr);
        }
        else
        return false;
}

function XmlLoader($strXml)
{
    set_error_handler('HandleXmlError');
        $dom = new DOMDocument();
	    $dom->loadXml($strXml);
	        restore_error_handler();
		    return $dom;
		    }
   
// Load the XML source
try{
	$xml = xmlLoader($result1);
   }
	catch(Throwable $e){
	echo $e;
	echo "\n\n";
	echo $result1;
    }

# Select the stylesheet based on web form input
$xsl = new DOMDocument;
if(strtoupper($returnForm) == 'CSV'){
	$xsl->load('resultset2csv.xsl');
	header('Content-type: text/csv');
	header('Content-Disposition: attachment; filename=resultSet.csv');
}elseif (strtoupper($returnForm) == 'HTML'){
	$xsl->load('resultset2catalog.xsl');
}else{
	$xsl->load('resultset2txt.xsl');
	header('Content-type: text/plain');
}
// Configure the transformer
$proc = new XSLTProcessor;
$proc->importStyleSheet($xsl); // attach the xsl rules

echo $proc->transformToXML($xml);

curl_close($ch);

?>