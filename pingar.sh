#!/bin/bash

MEDIA=0

# INFORMACOES
# O primeiro valor é o número de pings
# O segundo valor é o endereço IP que vai receber o ping
# O tempo de cada repeticao pode demorar até 2 segundos 
# somasse 3 segundos para o relatorio de ping ser criado
# Retorna 0 caso o IP não seja encontrado


for i in $(seq $1); do
	SAIDA=`ping -c 1 -w 3 $2 | grep time= | awk -F"=" '{print $4}'`;
	SAIDA="${SAIDA%.*}"
	SAIDA="${SAIDA%ms}"
	MEDIA=$((SAIDA+MEDIA))
done
MEDIA=$((MEDIA/$1));
MEDIA=$((MEDIA+1)); 

echo ${MEDIA}
