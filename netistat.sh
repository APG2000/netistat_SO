function get_data_since_startup(){
    readarray rx_atual <<< $(ifconfig |sort | grep RX | grep bytes | awk '{print $5}' )
    readarray tx_atual <<< $(ifconfig |sort | grep TX | grep bytes | awk '{print $5}' )
}



function get_bytes(){
    get_data_since_startup
    for ((i=0; i<${#ri[@]}; i++)) ; do
        let rx[$i]=(rx_atual[$i]-ri[$i])/s
        let tx[$i]=(tx_atual[$i]-ti[$i])/s
    done
}

# O ifconfig dá o numero de pacotes e bits que passou por cada interface desde o startup do pc
# no entanto queremos a variação desde que corremos o programa t, até ao intervalo que o ultilizador meteu t+s:
# Para corremos get_data_since_startup() 1 vez no inicio para termos rx e rt inicial na linha 99 e outra para atualizar os arrays quando formos calcular a variação
# no get_bytes

function get_inter(){
    readarray inter <<< $(ifconfig| sort | grep -E 'inet|ether' -v | grep : | awk '{print $1}' | cut -d ":" -f1)
}

# Esta função dá nos as interfaces

function get_rate(){
    get_bytes
    for ((i=0; i<${#ri[@]}; i++)) ; do
        let rr[$i]=rx[$i]/s
        let rt[$i]=tx[$i]/s
    done
}

# Nesta função obtemos o trate e xrate dividindo a variação de bytes medida com a função get_bytes

function print_dados(){
    get_rate
    for ((i=0; i<${#ri[@]}; i++)) ; do
        printf "%-10s\t%10s\t%10s\t%10s\t%10s\n" ${inter[$i]} ${tx[$i]} ${rx[$i]} ${rt[$i]} ${rr[$i]}
    done
}

function print_tabela(){
    printf "%-10s\t%10s\t%10s\t%10s\t%10s\n" "NETIF" "TX" "RX" "TRATE" "RRATE"
    print_dados | sort $options
}

# Aqui está um truque que descobri, quando fazes um comando e dás sort do output o que acontece é que estás a dar sort do output imprimido, portanto ao fazer 
# uma função para imprimir dados consigo facilmente os ordenar consoante a diferentes opções dando pipe para o sort



# Opções
order_of_sort=""
reverse=0
regex=""
bytes=0
megabytes=0
loop=0

# Esta String são as varias opções que tens sendo que começa sempre por : e quando uma opção leva argumentos tbm leva : pontos á frente "...c:"

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

s=$1

# Isto é um rascunho que tinha antes de fazer as alterações por causa do loop
#while [[ l -eq 1 ]];do
    #print
    #sleep s
#done

get_data_since_startup
get_inter

# estes dois são necessários sempre correr no inicio para ter as interfaces e os bytes usados em cada interface quando começamos a correr o programa pois

ri=("${rx_atual[@]}")
ti=("${tx_atual[@]}")

options="-k 1 -d -r"

sleep $s

print_tabela

# Extras

# A função readarray var <<< $(comand) lê cada linha do comando para um array

# Quando obetenho os dados do ifconfig dou pipe para o sort pois se organizarmos para termos sempre as interfaces pela mesma ordem (alfabética) pois
# a bash ñ tem array multidimensionais, pelo que ñ dá pra fazer o que tinha pensado que era organizar os dados de cada interface no array dentro de um array de interfaces

# ifconfig |sort  | grep RX --> vai buscar todas as linhas que tenha RX | grep bytes --> vai buscar todas as linhas com bytes | awk '{print $5}' --> imprime a coluna 5

# As interfaces tem sempre dois pontos á frente pelo que seria facil ir buscalas por ai mas como o Ipv6 tbm tẽm fiz o seguinte
# ifconfig| sort | grep -E 'inet|ether' --> Seleciona todas linhas com inet ou ether -v --> inverte a seleção | grep : --> agora sem o Ipv6 a chatear é só dar grep pelos dois pontos| awk '{print $1}' | cut -d ":" -f1