#!/usr/bin/bash

if [ -z $2 ]
then
	echo "Instrucao de uso: $0 dominio.com caminho_wordlist.txt"
	exit 1
fi



figlet "Information Gathering"
echo -e  "autor: 0c3x \n \n"

echo  -e "\033[01;31mServidores de Email\n \033[01;37m"

host -t mx $1 | cut -d" " -f7




echo  -e "\n\n\033[01;31mBrute-Force -> Listagem de diretorios e arquivos\n \033[01;37m"

for palavra in $(cat $2)
        do
                resposta=$(curl -s -o /dev/null -w "%{http_code}" $1/$palavra/)
        if  [ $resposta == "200" ]
        then
                echo "Diretorio Encontrado: $palavra"
        fi

               resposta=$(curl -s -o /dev/null -w "%{http_code}" $1/$palavra)
        if  [ $resposta == "200" ]
        then
                echo "Arquivo Encontrado: $palavra"
        fi

done



echo -e "\n\n\033[01;31mReverse DNS\033[01;37m\n"

#bloco inicial
endIpv4=$(host $1 | grep "has address"| cut -d" " -f4 | head -n1)

range=$(whois $endIpv4 | grep "inetnum" | head -n1 | cut -d: -f2 | sed s/" "//g)

isCidr=$(echo $range | cut -d/ -f3)

if [ -z $isCidr ];
then
        echo "é cidr"
        range=$(ipcalc $range | grep -A1 "HostMin" | cut -d" " -f4 | tr "\n" "x" | sed s/x/-/ | sed s/x//)

fi


terceiroOcMin=$(echo $range | cut -d- -f1 | cut -d. -f3)
terceiroOcMax=$(echo $range | cut -d- -f2 | cut -d. -f3)
quartoOcMin=$(echo $range | cut -d- -f1 | cut -d. -f4)
quartoOcMax=$(echo $range | cut -d- -f2 | cut -d. -f4)


doisOc=$(echo $endIpv4 | cut -d. -f1,2)

excepSearch=$(echo $doisOc | sed s/"\."/-/ | sed s/"\."/-/)

i=$terceiroOcMin
while [ $i -le $terceiroOcMax ];
do
        #TERCEIRO OCTETOS IGUAIS
        if [ $terceiroOcMin -eq $terceiroOcMax ];
        then
                for ip in $(seq $quartoOcMin $quartoOcMax);
                do
                        host "$doisOc.$i.$ip" | grep -v "$excepSearch" |
                        cut -d" " -f4,5 | sed s/pointer/"$doisOc.$i.$ip \-\-\>"/g;
                done
        fi


        #TERCEIRO OCTETOS DIFERENTES
        if [ $terceiroOcMin -ne $terceiroOcMax ];
        then
                if [ $i -eq $terceiroOcMin ];
                then
                        for ip in $(seq $quartoOcMin 255);
                        do
                                host "$doisOc.$i.$ip" | grep -v "$excepSearch" |
                                cut -d" " -f4,5 | sed s/pointer/"$doisOc.$i.$ip \-\-\>"/g;
                         done
                fi

                if [ $i -eq $terceiroOcMax ];
                then
                        for ip in $(seq 1 $quartoOcMax);
                        do
                                host "$doisOc.$i.$ip" | grep -v "$excepSearch" |
                                cut -d" " -f4,5 | sed s/pointer/"$doisOc.$i.$ip \-\-\>"/g ;
                        done
                fi

                if [ $i -ne $terceiroOcMin ] && [ $i -ne $terceiroOcMax ];
                then
                        for ip in $(seq 1 255);
                        do
                                host "$doisOc.$i.$ip" | grep -v "$excepSearch" |
                                cut -d" " -f4,5 | sed s/pointer/"$doisOc.$i.$ip \-\-\>"/g ;
                        done
                fi
        fi

        i=$[$i+1]
done


echo -e "\n\n\033[01;31mTransferencia de Zona\033[01;37m\n"

for ns in $(echo $(host -t ns $1 | cut -d" " -f4 | cut -d. -f1-4));
do
	host -l $1 $ns | grep "has address"
done


echo -e "\n\n\033[01;31mListagem Subdominios \033[01;37m\n"

for sub in $(cat /usr/share/dirb/wordlists/small.txt);
do
        host $sub.$1 | grep "has address"
done

