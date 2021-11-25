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

function get_inter(){
    readarray inter <<< $(ifconfig| sort | grep -E 'inet|ether' -v | grep : | awk '{print $1}' | cut -d ":" -f1)
}

function get_rate(){
    get_bytes
    for ((i=0; i<${#ri[@]}; i++)) ; do
        let rr[$i]=rx[$i]/s
        let rt[$i]=tx[$i]/s
    done
}

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

# Opções
order_of_sort=""
reverse=0
regex=""
bytes=0
megabytes=0
loop=0

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

#while [[ l -eq 1 ]];do
    #print
    #sleep $1
#done

get_data_since_startup
get_inter
ri=("${rx_atual[@]}")
ti=("${tx_atual[@]}")

options="-k 1 -d -r"

sleep $s

print_tabela
