#!/usr/bin/bash

if [ "$2" == "" ];
then
	echo "Você pode gerar um hash md5 do arquivo no linux."
	echo "COMMAND: md5sum arquivo.exe"
	echo
	echo "Modo de Uso: $0 5eeda96081af10635b381ddd20486e09 arquivo.exe";
	exit;
fi;

echo "CHECK MD5 - INTEGRIDADE"
echo
md=$(md5sum $2 | cut -d" " -f1 2> /dev/null)

if [ "$1" == "$md" ];
then
	echo "Arquivo integro";
else
	echo "Arquivo não está integro";
fi;
