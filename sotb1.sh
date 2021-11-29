#!/bin/bash
#ifconfig -a | sed 's/[ \t].*//;/^$/d' |cut -d ":" -f1  to get interfaces 

assert ()                
{                        

  if [ $a -le 0 ]
  then
    echo "Assertion failed: parâmetro obrigatório em falta (Tempo em segundos )"
    exit $E_ASSERT_FAILED
  # else
  #   return
  #   e continua a executar o script.
  fi  
}    


a=$# #numero de argumestos do script 
assert 


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

done
}

#|cut --complement -d ":" -f 1  # this cut the complement of an : ou seja a segunda parte
# awk '{print $2}' | cut -d ":" -f1 corta o primeiro

function getxrx(){

rx=$(ifconfig $1 |sort |grep packets | grep RX |awk  '{print $5}') #'{print $3}' is to access the collum with the value that we want 
tx=$(ifconfig $1 |sort |grep packets | grep TX |awk  '{print $5}')

}

function visualizar(){


case $opv in 

-m)


  if [[ $1 -ge 0 ]] 
  then
  {
    ## to convert the number to mb
#echo "scale=2; 10000 / 1024" | bc

  #txfi=$(echo "scale=2;  $txf / 1024" | bc) # bash nao suporta divisao com floats  so i... found this  /1000 desloca virgula 3x so que fica com x,xx nao func
  txfi=$(bc <<< 'scale=2; '$(echo "scale=2;  $txf / 1024" | bc)'/100') #this is better than the other fica x.x

  #rxfi=$(echo "scale=2;  $rxf / 1024" | bc)
  rxfi=$(bc <<< 'scale=2; '$(echo "scale=2;  $rxf / 1024" | bc)'/100')

  #txrate2i=$(echo "scale=2;  $txrate2 / 1024" | bc)
  txrate2i=$(bc <<< 'scale=2; '$(echo "scale=2;  $txrate2 / 1024" | bc)'/100') #converte para megabytes e divide por 100 para deslocar virgula

  #rxrate2i=$(echo "scale=2;  $rxrate2 / 1024" | bc) 

  rxrate2i=$(bc <<< 'scale=2; '$(echo "scale=2;  $rxrate2 / 1024" | bc)'/100')


  #tx=$(echo "scale=2;  $tx / 1024" | bc) 
  tx=$(bc <<< 'scale=2; '$(echo "scale=2;  $tx / 1024" | bc)'/100')

  #rx=$(echo "scale=2;  $rx / 1024" | bc) 

  rx=$(bc <<< 'scale=2; '$(echo "scale=2;  $rx / 1024" | bc)'/100')


  TXTOT2=$(bc <<< 'scale=2; '$tx'*1')

  RXTOT2=$(bc <<< 'scale=2; '$rx'*1')

  if [[ $1 -eq 1 ]]
  then
  printf "%-10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n" "$x"  "$txfi MB" "$rxfi Mb"  "$txrate2i"  "$rxrate2i MB" "$TXTOT2 MB" "$RXTOT2 MB"
  
  else
    printf "%-10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n" "$x"  "$txfi MB" "$rxfi Mb"  "$txrate2i MB"  "$rxrate2i MB" 

  fi

  }
  
fi

  #printf "%-10s\t%10s\t%10s\t%10s\t%10s\n" $x "$txfi MB" "$rxfi Mb" "$txrate2i MB" "$rxrate2i MB"   #print all interface and its values 
  ;;




-k)
  printf "%-10s\t%10s\t%10s\t%10s\t%10s\n" $x "$(($txf/1000)) KB" "$(($rxf/1000)) KB" "$(($txrate2/1000)) KB" "$(($rxrate2/1000)) KB"

;;

-b)
printf "%-10s\t%10s\t%10s\t%10s\t%10s\n" $x  "$txf B" "$rxf B"  "$txrate2 B" "$rxrate2 B"

;;

*)

echo error 
;;
esac


}

function printthings(){
#printf "%-10s\t%10s\t%10s\t%10s\t%10s\n" "NETIF" "TX" "RX" "TRATE" "RRATE"

getinterfaces ##this can make an ifconfig so first values are there
sleep $tempo

for x in "${!dicform[@]}" 

    do 
    {
        getxrx $x #$tempo #segundo argumento é o valor que se tem de passar ao getrxtx para poder dar sleep

        #echo $x ${animals[$x]}
        #txf e rxf =primeiro valor de tx e rx que é quando a função getintefaces é chamada
        # tx e fx x= ultimo valor de tx xe rx quando a função gettxrx é chamada


        tab="$x ${dicform[$x]} "          #|cut --complement -d ":" -f 1  #| awk '{print $2}' | cut -d ":" -f1
        txf=$(echo $tab | grep $x | awk '{print $2}' | cut -d ":" -f1 )
        rxf=$(echo $tab | grep $x | awk '{print $2}' | cut --complement -d ":" -f1 )

        ##get rx and tx final after slep
        txrate=$(($txf-$tx))  #$tempo
        rxrate=$(($rxf-$tx)) #$tempo

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
                if [[ $1 -eq 1 ]] #se tem arumento é para loop
                then

                      visualizar $loop # ultimo e penultimo saõ os valores de rxe tx desde o inicio da execução do programa
                fi

                if [[ $1 -le 0 ]]  ##caso a função nem tem argumento não é para loop
                then
                visualizar 
                fi

        }


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

  if [ $# -gt 1 ]  && [ $2 == "-l" ] #-----------------------------------loop here
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
#---main------------------------------Parte de execução do script-------------------------------main


echo "Qual a opção de visualização"

x="false"
  while [ $x != "True" ]

  do
    echo "escolha entre [-b -m -k]"
    read x

    if [ $x == "-b" ]
    then
    opv="-b"
    x="True"
    fi

    if [ $x == "-k" ]
    then
    opv="-k"
    x="True"
    fi

    if [ $x == "-m" ]
    then
      opv="-m"
      x="True"
    fi

  done

#----optei por não usar o getops e fiz dessa forma
#caso o script tenha 3 argumentos
{
if [[ $# -gt 2 ]]
then

tempo=$3

case $1 in
    -c)
            #regex=$OPTARG
    #echo "escolheu c"
    
    printlabel $2
    ;;
    esac


fi
}

#caso o script tenha 1 argumento que so pode ser o tempo (fazer assert depois )
{
if [ $# -eq 1 ]
then

tempo=$1
printlabel

fi
}


#caso o scirpt tenha 2 argumentos (fazer assert depois para validar e deixar o progama sem erro )
{
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
    

  printlabel $2  $1
  ;;

esac
fi
}

#  i think its all for now ahah
# depois pode-se melhorar algumas cenas 
# e falta tirar uma duvida na questão das opções do sort....
