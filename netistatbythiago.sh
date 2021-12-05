
# Vai bustar o fincheiro para o print inicial


assert() { #verifica a quantidade de argumentos
    re='^[0-9]+$'
    if ! [[ $s =~ $re ]]; then # se o argumento do tempo nao for um numero e o numero total de argumentos nao for igual ou superior a 2 o programa nao corre

        if [[ $n_arg -lt 2 ]]; then
            echo "Assertion failed: parâmetro obrigatório em falta (Tempo em segundos )"
            exit $E_ASSERT_FAILED
        fi
    fi
    if [ $n_arg -le 0 ]; then
        echo "Assertion failed: parâmetro obrigatório em falta (Tempo em segundos )"
        exit $E_ASSERT_FAILED
    fi

}

s=$1
n_arg=$#


assert
declare -A dicform_i
dicform_i=()
declare -A dicform_f
dicform_f=()

declare -A dicform_r
dicform_r=()


function getinterfaces() {
    for inter in $(ifconfig -a | grep -E "inet|ether" -v | grep : | awk '{print $1}' | cut -d ":" -f1); do 
        interfaces+=($inter)
    done
}

function getdicform() {
    for i in "${interfaces[@]}"; do
        dicform_f[$i]=$(ifconfig $i | sort | grep packets | grep TX | awk '{print $5}')
        dicform_f[$i]+=":"$(ifconfig $i | sort | grep packets | grep RX | awk '{print $5}')
    done
}


# Vai buscar os bytes do ifconfig -- que estão a contar desde o startup

# Calcula o Rrate e TRate dividido a variação pelo tempo introduzido,s.
# Imprime dados -- Esta função está separada da tabela para facilmente ordenarmos os dados dando 'pipe' da função ao sort
function print_dados() {
    getdicform
    for i in "${interfaces[@]}"; do
        

        linha_i="$i ${dicform_i[$i]}"
        linha_f="$i ${dicform_f[$i]}"
        linha_r="$i ${dicform_r[$i]}"


        

        rx_i=$(echo $linha_i | grep $i | awk '{print $2}' | cut --complement -d ":" -f1)

        tx_i=$(echo $linha_i | grep $i | awk '{print $2}' | cut -d ":" -f1)

        r_inicial=$(echo $linha_r | grep $i | awk '{print $2}' | cut --complement -d ":" -f1)

        t_inicial=$(echo $linha_r | grep $i | awk '{print $2}' | cut -d ":" -f1)
        

        

        rx_f=$(echo $linha_f | grep $i | awk '{print $2}' | cut --complement -d ":" -f1)
    
        tx_f=$(echo $linha_f | grep $i | awk '{print $2}' | cut -d ":" -f1)


        let rx=rx_f-rx_i
     
        let tx=tx_f-tx_i

        let t_total=t_inicial+tx
        echo "$t_inicial --> t_inicial"
        echo "$t_total --> t_total"
        let r_total=r_inicial+rx
        echo "$r_total --> r_total"
        echo "$r_inicial --> r_inicial"

    
        rr=$( bc <<< "scale=2; $rx / $s" )
        tr=$( bc <<< "scale=2; $tx / $s" )

        
        

        case $opv in
            0)
                if [[ loop -ne 0 ]]; then
                    printf "%-10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n" "$i" "$tx B" "$rx B" "$tr B/s" "$rr B/s" "$t_total B" "$r_total B"
                else
                    printf "%-10s\t%10s\t%10s\t%10s\t%10s\n" "$i" "$tx B" "$rx B" "$tr B/s" "$rr B/s"
                fi

                ;;

            1)
                rx=$(bc <<<"scale=2;$rx/1000000")
                tx=$(bc <<<"scale=2;$tx/1000000")

                rr=$(bc <<<"scale=2;$rr/1000000")
                tr=$(bc <<<"scale=2;$tr/1000000")

                if [[ $loop -ne 0 ]]; then
                    printf "%-10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n" "$i" "$tx MbB" "$rx Mb" "$tr Mb/s" "$rr Mb/s" "$t_total Mb" "$r_total Mb"
                else
                    printf "%-10s\t%10s\t%10s\t%10s\t%10s\n" "$i" "$tx Mb" "$rx Mb" "$tx Mb" "$rr Mb"
                fi

                ;;
            2)
                rx=$(bc <<<"scale=2;$rx/1000")
                tx=$(bc <<<"scale=2;$tx/1000")

                rr=$(bc <<<"scale=2;$rr/1000")
                tr=$(bc <<<"scale=2;$tr/1000")

                if [[ $loop -ne 0 ]]; then
                    printf "%-10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n" "$i" "$tx Kb" "$rx Kb" "$tr Kb/s" "$rr Kb/s" "$t_total Kb" "$r_total Kb"
                else
                    printf "%-10s\t%10s\t%10s\t%10s\t%10s\n" "$i" "$tx Kb" "$rx Kb" "$tx Kb" "$rr Kb"
                fi
        esac
        dicform_r[$i]=$(echo $t_total)
        dicform_r[$i]=":"$(echo $r_total)

    done
   
}

# Imprime a tabela -- output


n_arg=$#
s=${@: -1}

# Opções usadas
order_of_sort=""
reverse=0
#regex="cat" dont need 
opv=0
loop=0
head=  #what is this ??


# Este comando executa antes de tudo lendo as opções -- A String começa sempre por :, e quando uma opção leva argumentos tbm como vemos na opção c. Além disso para sempre antes do primeiro argumento que ñ é uma opção
while getopts bc:lmp:rRtTvk option ; do
    case $option in
    c)
    c_option="true"
    grepby=$OPTARG
     ;;
    k)  opv=2;;
    l)  loop=1;;
    m)  opv=1;;
    p)  n_head="-"$(echo $OPTARG);;
    r)  order_of_sort="-k 3 -n";;
    R)  order_of_sort="-k 5 -n";;
    t)  order_of_sort="-k 2 -r";;  ## so here is -r to make it iqual to the pdf example
    T)  order_of_sort="-k 4 -n";;
    v)  reverse=1;;
    esac
done

# Concatenação de  -r ás opções do sort

if [[ reverse -eq 0 ]] ; then
    order_of_sort=$(echo $order_of_sort)" -r"
fi 

# Declaração de uma estrutura a que chamamos de dicform que é semelhante a um dicionário em python ou um Map em Java que é um array que aceita como indices strings
declare -A dicform_i
dicform_i=()
declare -A dicform_f
dicform_f=()

declare -A dicform_r
dicform_r=()
# Imprime dados -- Esta função está separada para facilmente ordenarmos os dados dando 'pipe' da função ao sort
function print_dados() {
    getdicform
    for i in "${interfaces[@]}"; do
        linha_i="$i ${dicform_i[$i]}"
        linha_f="$i ${dicform_f[$i]}"
        linha_r="$i ${dicform_r[$i]}"

        rx_i=$(echo $linha_i | grep $i | awk '{print $2}' | cut --complement -d ":" -f1)
        tx_i=$(echo $linha_i | grep $i | awk '{print $2}' | cut -d ":" -f1)

        r_inicial=$(echo $linha_r | grep $i | awk '{print $2}' | cut --complement -d ":" -f1)
        t_inicial=$(echo $linha_r | grep $i | awk '{print $2}' | cut -d ":" -f1)
        
        rx_f=$(echo $linha_f | grep $i | awk '{print $2}' | cut --complement -d ":" -f1)
        tx_f=$(echo $linha_f | grep $i | awk '{print $2}' | cut -d ":" -f1)

        let rx=rx_f-rx_i     
        let tx=tx_f-tx_i

        let r_total=rx_f-r_inicial
        let t_total=tx_f-t_inicial
        
        rr=$( bc <<< "scale=2; $rx / $s" )
        tr=$( bc <<< "scale=2; $tx / $s" )

        case $opv in # ver se é para imprimir em bytes/Mb ou Kb
            0)
                if [[ loop -ne 0 ]]; then
                    printf "%-10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n" "$i" "$tx B" "$rx B" "$tr B/s" "$rr B/s" "$t_total B" "$r_total B"
                else
                    printf "%-10s\t%10s\t%10s\t%10s\t%10s\n" "$i" "$tx B" "$rx B" "$tr B" "$rr B"
                fi

                ;;
            1)
                rx=$(bc <<<"scale=2;$rx/1000000")
                tx=$(bc <<<"scale=2;$tx/1000000")

                rr=$(bc <<<"scale=2;$rr/1000000")
                tr=$(bc <<<"scale=2;$tr/1000000")

                t_t=$(bc <<<"scale=2;$t_total/1000000")
                r_t=$(bc <<<"scale=2;$r_total/1000000")

                if [[ $loop -ne 0 ]]; then
                    printf "%-10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n" "$i" "$tx Mb" "$rx Mb" "$tr Mb/s" "$rr Mb/s" "$t_t Mb" "$r_t Mb"
                else
                    printf "%-10s\t%10s\t%10s\t%10s\t%10s\n" "$i" "$tx Mb" "$rx Mb" "$tx Mb" "$rr Mb"
                fi

                ;;
            2)
                rx=$(bc <<<"scale=2;$rx/1000")
                tx=$(bc <<<"scale=2;$tx/1000")

                rr=$(bc <<<"scale=2;$rr/1000")
                tr=$(bc <<<"scale=2;$tr/1000")

                t_t=$(bc <<<"scale=2;$t_total/1000")
                r_t=$(bc <<<"scale=2;$r_total/1000")

                if [[ $loop -ne 0 ]]; then
                    printf "%-10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n" "$i" "$tx Kb" "$rx Kb" "$tr Kb/s" "$rr Kb/s" "$t_t Kb" "$r_t Kb"
                else
                    printf "%-10s\t%10s\t%10s\t%10s\t%10s\n" "$i" "$tx Kb" "$rx Kb" "$tx Kb" "$rr Kb"
                fi
        esac


    done
   
}

function inicial_setup(){ #Setup inicial
    getinterfaces
    for i in "${interfaces[@]}"; do
        dicform_i[$i]=$(ifconfig $i | sort | grep packets | grep TX | awk '{print $5}')
        dicform_i[$i]+=":"$(ifconfig $i | sort | grep packets | grep RX | awk '{print $5}')
        dicform_r[$i]=$(ifconfig $i | sort | grep packets | grep TX | awk '{print $5}')
        dicform_r[$i]+=":"$(ifconfig $i | sort | grep packets | grep RX | awk '{print $5}')
    done
    if [[ $loop -eq 0 ]] ; then
        printf "%-10s\t%10s\t%10s\t%10s\t%10s\n\n" "NETIF" "TX" "RX" "TRATE" "RRATE"
    else
        printf "%-10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n\n" "NETIF" "TX" "RX" "TRATE" "RRATE" "TXTOT" "RXTOT"
    fi
    sleep $s
}

function getinterfaces() { # Recolher as interfaces
    for inter in $(ifconfig -a | sed 's/[ \t].*//;/^$/d' | cut -d ":" -f1); do
        interfaces+=($inter)
    done
}

function getdicform() { # Recolher os dados mais recentes das interfaces
    for i in "${interfaces[@]}"; do
        dicform_f[$i]=$(ifconfig $i | sort | grep packets | grep TX | awk '{print $5}')
        dicform_f[$i]+=":"$(ifconfig $i | sort | grep packets | grep RX | awk '{print $5}')
    done
}

inicial_setup

if [[ $loop -eq 1 ]]; then # parte do loop caso seja selecionada a opção -l
    while true ; do
          if [[ $c_option == "true" ]]
    then
    print_dados |  sort $order_of_sort |grep $grepby | head $n_head # parte não loop
    else

    print_dados |  sort $order_of_sort | head $n_head # parte não loop
    fi
        for i in "${interfaces[@]}"; do
            dicform_i[$i]=$(ifconfig $i | sort | grep packets | grep TX | awk '{print $5}')
            dicform_i[$i]+=":"$(ifconfig $i | sort | grep packets | grep RX | awk '{print $5}')
        done 
        sleep $s
        echo "----------------------------------------------------------------------------------------------------------"
        printf "%-10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n\n" "NETIF" "TX" "RX" "TRATE" "RRATE" "TXTOT" "RXTOT"
    done
else
    if [[ $c_option == "true" ]]
    then
    print_dados |  sort $order_of_sort  |grep $grepby | head $n_head # parte não loop
    else

    print_dados |  sort $order_of_sort | head $n_head # parte não loop
    fi
fi

