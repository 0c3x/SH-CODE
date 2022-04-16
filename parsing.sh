#!/usr/bin/bash

if [ $1 == ""]
then
  echo "instrucao de uso:"
  echo "ex: $0 site.com.br"
 else
  figlet 'parsing'
  echo
  
  wget -q $1
  mv index.html $1.txt
  lista_urls=$(cat $1.txt| grep "href" | grep "// | cut -d "/" -f3 | cut -d '"' -f1 | sort -u)
  
  for url in $lista_urls
  do
    host $url | grep "has address"
  done
  
  rm $1.txt
fi
