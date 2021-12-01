declare -A dicform

dicform=() # dados
interfaces=()
s=$1
function getinterfaces(){
  for xi in $(ifconfig| sort | grep -E 'inet|ether' -v | grep : | awk '{print $1}' | cut -d ":" -f1) ; do # assim as interfaces vem pela ordem que foram adicionadas, se ñ for feito assim uma interface pode ser adicionada enquanto o programa estiver a correr e se começar pela uma letra antes do e até ao v e trocar a ordem das interfaces. 
    #echo $xi
    interfaces+=($xi)
  done 
}

function getdata(){
    for i in "${interfaces[@]}" ; do
      rx_i=$(echo ${dicform_i[$i]} | awk '{print $1}')
      tx_i=$(echo ${dicform_i[$i]} | awk '{print $2}')
      rx_f=$(ifconfig $i | sort |grep bytes | grep TX |awk  '{print $5}') 
      tx_i=$(ifconfig $i | sort |grep bytes | grep RX |awk  '{print $5}')
      let rx=(rx_f-rx_i)
      let tx=(tx_f-tx_i)
      rr=$(bc <<< "scale=2;(($rx/$s))")
      rt=$(bc <<< "scale=2;(($tx/$s))")
      dicform[$i]=$rx
      dicform[$i]+=" "$tx
      dicform[$i]+=" "$rr
      dicform[$i]+=" "$rt
    done
}
### Setup inicial
getinterfaces

declare -A dicform_i

dicform_i=()

for i in "${interfaces[@]}" ; do
      #printf "%-10s\t%10s\t%10s\n" $i  $tx $rx
      dicform_i[$i]=$(ifconfig $i |sort |grep bytes | grep TX |awk  '{print $5}')  
      dicform_i[$i]+=" "$(ifconfig $i |sort |grep bytes | grep RX |awk  '{print $5}')
done
sleep $s
getdata
for i in "${interfaces[@]}" ; do
      echo $i   ${dicform_i[$i]}
done