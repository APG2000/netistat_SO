ifconfig
# Vai buscar os bytes do ifconfig -- que estão a contar desde o startup
function get_data_since_startup(){
    readarray rx_atual <<< $(ifconfig |sort | grep RX | grep bytes | awk '{print $5}' )
    readarray tx_atual <<< $(ifconfig |sort | grep TX | grep bytes | awk '{print $5}' )
}
# Faz o variação de  rx e tx em s, subtraindo o valor incial pelo valor quando a função é chamada -- valor que temos que apresentar 
function get_bytes(){
    get_data_since_startup
    for ((i=0; i<${#ri[@]}; i++)) ; do
        let rx[$i]=(rx_atual[$i]-ri[$i])/s
        let tx[$i]=(tx_atual[$i]-ti[$i])/s
    done
}
# Vai buscar interfaces

function get_inter(){
    readarray inter <<< $(ifconfig| sort | grep -E 'inet|ether' -v | grep : | awk '{print $1}' | cut -d ":" -f1)
}

# Calcula o Rrate e TRate dividido a variação pelo tempo introduzido,s.
function get_rate(){
    get_bytes
    for ((i=0; i<${#ri[@]}; i++)) ; do
        let rr[$i]=rx[$i]/s
        let rt[$i]=tx[$i]/s
    done
}
# Imprime dados -- Esta função está separada da tabela para facilmente ordenarmos os dados dando 'pipe' da função ao sort
function print_dados(){
    get_rate
    for ((i=0; i<${#ri[@]}; i++)) ; do
        printf "%-10s\t%10s\t%10s\t%10s\t%10s\n" ${inter[$i]} ${tx[$i]} ${rx[$i]} ${rt[$i]} ${rr[$i]}
    done
}
# Imprime a tabela -- output
function print_tabela(){
    printf "%-10s\t%10s\t%10s\t%10s\t%10s\n" "NETIF" "TX" "RX" "TRATE" "RRATE"
    print_dados | sort $options
}

# Opções usadas
order_of_sort=""
reverse=0
regex=""
bytes=0
megabytes=0
loop=0
# Este comando executa antes de tudo lendo as opções -- A String começa sempre por :, e quando uma opção leva argumentos tbm como vemos na opção c
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
            get_bytes
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
# tempo intruduzido, argumento obrigatório, falta fazer o assert
s=$1
#rascunho do loop que já cá estava

#while [[ l -eq 1 ]];do
    #print
    #sleep $1
#done

# Dados iniciais
get_data_since_startup
get_inter
ri=("${rx_atual[@]}")
ti=("${tx_atual[@]}")

# Exemplo de opções para o Sort
options="-k 2 -n "

# Pausamos o program s segundos para depois medirmos os valores
sleep $s

#output
print_tabela

# Extras

# readarray var -- le cada linha para um elemento do array

# ifconfig |sort -- para termos as interfaces sempre pela mesma ordem *| grep RX -- seleciona pela keyword RX | grep bytes -- "" "" bytes| awk '{print $5}' imprime a coluna 5
# * eu queria ivitar isto mas a bash ñ suporta  arrays multidimensionais portanto tiro as interfaces e os dados sempre pela mesma ordem

# ifconfig| sort |* grep -E 'inet|ether' -- Seleciona lihas com inet ou ether -v --faz a inversão da seleção | grep : | awk '{print $1}' | cut -d ":" -f1 -- corta o ultimo caracter ":"
# * Uma maneira simples de selecionar as interfaces é pelos ":", no entanto os endereços Iv6 vem atrás com este comando livro-me dessas linha 