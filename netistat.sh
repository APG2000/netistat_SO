#!/bin/bash
# Vai bustar o fincheiro para o print inicial

#inclui o ficheiro para printar com fonts
#DIR="${BASH_SOURCE%/*}"
#if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
#. "$DIR/fonts.sh"

#exitcode=$?

assert() { #verifica a quantidade de argumentos
    re='^[0-9]+$'
    if ! [[ $s =~ $re ]]; then # se o primeiro argumento nao for um numero e o numero total de argumentos nao for igual ou superior a 2 o programa nao corre

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

declare -A dicform_i
dicform_i=()
declare -A dicform_f
dicform_f=()

declare -A dicform_r
dicform_r=()


function getinterfaces() {

    # Add new element at the end of the array
    for inter in $(ifconfig -a | sed 's/[ \t].*//;/^$/d' | cut -d ":" -f1); do
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


        r_total=$(echo $linha_r | grep $i | awk '{print $2}' | cut --complement -d ":" -f1)
    
        t_total=$(echo $linha_r | grep $i | awk '{print $2}' | cut -d ":" -f1)
        
        
        

        let rx=rx_f-rx_i
     
        let tx=tx_f-tx_i


        

        
        
    
        rr=$( bc <<< "scale=2; $rx / $s" )
        tr=$( bc <<< "scale=2; $tx / $s" )

        let t_total=t_total+tx
        let r_total=r_total+rx
        

        case $opv in
            0)
                if [[ loop -ne 0 ]]; then
                    #rt=$(bc <<<"scale=2;$rt+$rx")
                    #tt=$(bc <<<"scale=2;$rt+$rx")
                    printf "%-10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n" "$i" "$tx B" "$rx B" "$tr B" "$rr B" "$t_total B" "$r_total B"
                else
                    printf "%-10s\t%10s\t%10s\t%10s\t%10s\n" "$i" "$tx B" "$rx B" "$tr B" "$rr B"
                fi

                ;;

            1)
                rx=$(bc <<<"scale=2;$rx/1000000")
                tx=$(bc <<<"scale=2;$tx/1000000")

                rr=$(bc <<<"scale=2;$rr/1000000")
                tr=$(bc <<<"scale=2;$tr/1000000")

                if [[ $loop -ne 0 ]]; then
                    #rt=$(bc <<<"scale=2;$rt+$rx")
                    #tt=$(bc <<<"scale=2;$rt+$rx")
                    printf "%-10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n" "$i" "$tx B" "$rx B" "$tr B" "$rr B" "$t_total B" "$r_total B"
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
                    #rt=$(bc <<<"scale=2;$rt+$rx")
                    #tt=$(bc <<<"scale=2;$rt+$rx")
                    printf "%-10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n" "$i" "$tx B" "$rx B" "$tr B" "$rr B" "$t_total B" "$r_total B"
                else
                    printf "%-10s\t%10s\t%10s\t%10s\t%10s\n" "$i" "$tx Kb" "$rx Kb" "$tx Kb" "$rr Kb"
                fi
        esac

        dicform_r[$i]=$(echo $t_total)
        dicform_r[$i]=":"$(echo $r_total)
        
    done
   
}

# Imprime a tabela -- output


# Opções usadas
order_of_sort=""
reverse=0
regex=""
opv=0
loop=1
# Este comando executa antes de tudo lendo as opções -- A String começa sempre por :, e quando uma opção leva argumentos tbm como vemos na opção c
while getopts :bc:lmrRtTvk option ; do
    case $option in

    b)

        opv=0
        ;;
    c)
        regex=$OPTARG
        ;;
    k)
        opv=1
        ;;
    l)
        loop=1
        ;;
    m)
        opv=2
        ;;
    r)
        order_of_sort="-k 2 -n"
        ;;
    R)
        order_of_sort="-k 2 -n"
        ;;
    t)
        order_of_sort="-k 2 -n"

        ;;
    T)
        order_of_sort="-k 2 -n"
        ;;

    v)
        reverse=1
        ;;
    
    esac
done
# tempo intruduzido, argumento obrigatório, falta fazer o assert
s=$1


assert
# Dados iniciais

getinterfaces
for i in "${interfaces[@]}"; do
    dicform_i[$i]=$(ifconfig $i | sort | grep packets | grep TX | awk '{print $5}')
    dicform_i[$i]+=":"$(ifconfig $i | sort | grep packets | grep RX | awk '{print $5}')
    dicform_r[$i]="0:0"
done
sleep $s
while true ; do
    print_dados
    echo "------------"
    for i in "${interfaces[@]}"; do
        dicform_i[$i]=$(ifconfig $i | sort | grep packets | grep TX | awk '{print $5}')
        dicform_i[$i]+=":"$(ifconfig $i | sort | grep packets | grep RX | awk '{print $5}')
    done
    sleep $s
done

# Exemplo de opções para o Sort
options="-k 2 -n "



# Extras

# readarray var -- le cada linha para um elemento do array

# ifconfig |sort -- para termos as interfaces sempre pela mesma ordem *| grep RX -- seleciona pela keyword RX | grep bytes -- "" "" bytes| awk '{print $5}' imprime a coluna 5
# * eu queria ivitar isto mas a bash ñ suporta  arrays multidimensionais portanto tiro as interfaces e os dados sempre pela mesma ordem

# ifconfig| sort |* grep -E 'inet|ether' -- Seleciona lihas com inet ou ether -v --faz a inversão da seleção | grep : | awk '{print $1}' | cut -d ":" -f1 -- corta o ultimo caracter ":"
# * Uma maneira simples de selecionar as interfaces é pelos ":", no entanto os endereços Iv6 vem atrás com este comando livro-me dessas linha
