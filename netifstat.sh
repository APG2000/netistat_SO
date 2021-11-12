
#!/bin/bash

# As operações de sort terão que ser feitas antes de retornar os dados por causa dos valores numéricos que vão ser alterados 
#
readarray arr <<< $(netstat -i | grep -E 'Kernel|Iface' -v |sort -k 3 -r -n| awk '{print $1,$3,$7}')


# Depois o sort pode ser feito com algo do tipo dependo das opções

arr1=("etho" 123456 23456 12345.6 2345.6)
arr2=("lo" 456 234 45.6 90.4)
printf "%s\t%s\t%s\t%s\t%s\n%s\t%s\t%s\t%s\t%s\n" ${arr1[0]} ${arr1[1]} ${arr1[2]} ${arr1[3]} ${arr1[4]} ${arr2[0]} ${arr2[1]} ${arr2[2]} ${arr1[3]} ${arr2[4]} | sort -k 1 -d -r