#!/usr/bin/python3

import urllib.request

# query parameters 
defType="edismax" 
queryText="author:*" 
scopeSearch=["scope:knb-lter-sbc","-scope:ecotrends","-scope:lter-landsat*"] 
fieldsReturned='*' 
sortList=["score,desc","packageid,asc"] 
doDebug="false" 
startRecord=0 
returnNumRows=10

queryString="defType="+defType 
if (len(queryText) > 0): 
    queryString +="&q="+queryText 
for scope in scopeSearch: 
    queryString+="&fq="+scope 
if (len(fieldsReturned) > 0): 
    queryString+="&fl="+fieldsReturned 
for sort in sortList: 
    queryString+="&sort="+sort 
if (len(doDebug) > 0): 
    queryString+="&debug="+doDebug 
if (startRecord > 0): 
    queryString+="&start="+str(startRecord) 
if (returnNumRows > 0): 
    queryString+="&rows="+str(returnNumRows) 
print(queryString) 

u=urllib.request.urlopen("https://pasta-d.lternet.edu/package/search/eml?"+queryString) 

print(u.read().decode('utf-8'))

