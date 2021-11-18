#!/bin/bash
if if [[ $1 != [0-9]* ]]; then 
exit 1
fi


# As operações de sort terão que ser feitas antes de retornar os dados por causa dos valores numéricos que vão ser alterados 
#
ifconfig | sort > output

readarray interfaces <<< $(cat output | grep -E 'inet|ether' -v | grep : | awk '{print $1}' | cut -d ":" -f1)
readarray R_bytes <<< $(cat output | grep bytes | grep RX | awk '{print $5}');
readarray R_packages <<< $(cat output | grep bytes | grep RX | awk '{print $3}');
readarray T_bytes <<< $(cat output | grep bytes | grep TX | awk '{print $5}');
readarray T_packages <<< $(cat output | grep bytes | grep TX | awk '{print $3}');


s = $1

# Opções
order_of_sort=""
reverse=0
regex=""
bytes=0
megabytes=0
loop=0

sleep $1

while getopts ":bc:lmrRtTv" option;
    do
        case $option in

        b)

            bytes=1
            ;;
        c)
            regex=$OPTARG
            ;;

        l)
            loop=1
            ;;
        
        m)
            megabytes=1
            ;;
        
        r)
            order_of_sort="RX"
            ;;
        R)
            order_of_sort="RRATE"
            ;;
        t)
            order_of_sort="TX"
            ;;
        T)
            order_of_sort="TRATE"
            ;;

        v)
            reverse=1
            ;;
        esac
done

#while [[ l -eq 1 ]];do
    #print
    #sleep $1
#done

# Depois o sort pode ser feito com algo do tipo dependo das opções

arr1=("etho" 123456 23456 12345.6 2345.6)
arr2=("lo" 456 234 45.6 90.4)
options="-k 1 -d -r"
printf "%s\t%s\t%s\t%s\t%s\n%s\t%s\t%s\t%s\t%s\n" ${arr1[0]} ${arr1[1]} ${arr1[2]} ${arr1[3]} ${arr1[4]} ${arr2[0]} ${arr2[1]} ${arr2[2]} ${arr1[3]} ${arr2[4]} | sort $options