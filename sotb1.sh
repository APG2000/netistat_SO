#!/bin/bash
#ifconfig -a | sed 's/[ \t].*//;/^$/d' |cut -d ":" -f1 


#echo "${animals[moo]}"

#animals['moo']+=' value2'
#animals['moo']+=' value3'

declare -A dicform

dicform=()
interfaces=()

function getinterfaces(){

# Add new element at the end of the array
for xi in $(ifconfig -a | sed 's/[ \t].*//;/^$/d' |cut -d ":" -f1 ) ## nome dos interfaces 
do 
#echo $xi
interfaces+=($xi)
done 

for i in "${interfaces[@]}"
do
     #printf "%-10s\t%10s\t%10s\n" $i  $tx $rx
dicform[$i]=$(ifconfig $i |sort |grep packets | grep TX |awk  '{print $5}')  

dicform[$i]+=":"$(ifconfig $i |sort |grep packets | grep RX |awk  '{print $5}')     #'{print $3}' is to access the collum with the value that we want 


#printf "%-10s\t%10s\t%10s\n" $i  $tx $rx  #print all interface and its values 

done
}

#animals[$x]='values after'


#|cut --complement -d ":" -f 1  # this cut the complement of an : ou seja a segunda parte
# awk '{print $2}' | cut -d ":" -f1 corta o primeiro


function getxrx(){


#echo $1

rx=$(ifconfig $1 |sort |grep packets | grep RX |awk  '{print $5}') #'{print $3}' is to access the collum with the value that we want 
tx=$(ifconfig $1 |sort |grep packets | grep TX |awk  '{print $5}')

}


function printthings(){
#printf "%-10s\t%10s\t%10s\t%10s\t%10s\n" "NETIF" "TX" "RX" "TRATE" "RRATE"

getinterfaces ##this can make an ifconfig so first values are there
sleep $tempo

for x in "${!dicform[@]}" 

do 


getxrx $x #$tempo #segundo argumento é o valor que se tem de passar ao getrxtx para poder dar sleep




#echo $x ${animals[$x]}

tab="$x ${dicform[$x]} "          #|cut --complement -d ":" -f 1  #| awk '{print $2}' | cut -d ":" -f1
txinicial=$(echo $tab | grep $x | awk '{print $2}' | cut -d ":" -f1 )
rxinicial=$(echo $tab | grep $x | awk '{print $2}' | cut --complement -d ":" -f1 )


##get rx and tx final after slep



txrate=$(($txinicial-$tx))  #$tempo

rxrate=$(($rxinicial-$tx)) #$tempo


txrate2=$(($txrate/$tempo ))
rxrate2=$(($rxrate/$tempo ))
if [ $txrate2 -le 0 ]
then 
txrate2=$tx
fi

if [ $rxrate2 -le 0 ] 
then
rxrate2=$rx
fi

{
if [[ $1 -eq 1 ]]
then
      printf "%-10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n" $x  $txinicial $rxinicial  $txrate2  $rxrate2 $txinicial $rxinicial

else

printf "%-10s\t%10s\t%10s\t%10s\t%10s\n" $x  $txinicial $rxinicial  $txrate2  $rxrate2 #print all interface and its values 

fi
}


done

}


function print1(){
    printf "%-10s\t%10s\t%10s\t%10s\t%10s\n" "NETIF" "TX" "RX" "TRATE" "RRATE"

}

function printlabel(){

    if [ $# -le 0 ]
    then 
    print1
    printthings
    fi


    if [ $# -eq 1 ]  # i use this for the comands grep
    then
    print1
    printthings |grep $1
    fi
    
    {
    if [ $# -gt 1 ]  && [ $2 != "-l" ] # i use this for the comand sort   ask theacher for this shit sort 
    then
    print1
    #echo "this is argument 1:"$1 "this is argument 2" :$2
    
    case $2 in
    -r)
    option="-r"
    ;;

     -t)
    option="-r"
    ;;

    -T)
    option="-n"
    ;;

    -R)
    option="-n"
    ;;
   

    esac
    printthings | sort $option # sort by argument 2 tha isnt a numeber 
   fi
    }

  if [ $# -gt 1 ]  && [ $2 == "-l" ]
  then 
    loop=1
      printf "%-10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n" "NETIF" "TX" "RX" "TRATE" "RRATE" "TXTOT" "RXTOT"

  
        while [ $2 == "-l" ]
        do
        printthings $loop 
        printf "\n"  
        done


  fi

    

}
#---main 

if [ $# -gt 2 ]
then
{

echo "arg 1 $1 Arg2 $2 Arg3 $3 " 
tempo=$3

case $1 in
    -c)
            #regex=$OPTARG
    echo "escolheu c"
    
    printlabel $2
    ;;

   

    

    esac

}
fi


if [ $# -eq 1 ]
then
{
tempo=$1
printlabel 

}
fi

if [ $# -eq 2 ] 
then
tempo=$2
case $1 in 
 -r)
    printlabel $2 $1
    ;;

   

-T)
printlabel $2 $1
;;

-R)
printlabel $2 $1
;;

-t)
printlabel $2 $1 
;;
-l)


printlabel $2 $1 

esac
fi