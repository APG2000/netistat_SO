#!/bin/bash
#ANSI Shadow.flf best font 
  
function run (){
cd figlet-fonts-master

font="ANSI Shadow.flf"
     #echo $(which figlet)

    
    echo "Verificando dependencias... "
    sleep 2

    name="figlet"

    #verifica se os programas estao instalados

    dpkg -s $name &> /dev/null  

    if [[ $(which figlet) == "" ]]

        then
                    echo "$name not installed"
                    sleep 1 
                    printf "\t ttrying to install "$name" (if password requered please insert it)"
                    
                    sleep 1
                    echo
                    echo  
                    sudo apt-get update
                    sudo apt-get install $name
                    exitcode=$(echo $?)

                    if [[ $exitcode -ne 0 ]]
                    then
                        echo "error trying to install $name "
                        sleep 1 
                        clear
                    else
                        echo "install Success "
                        sleep 1 
                        clear

                    a=$(pwd)
                    figlet -f $a/"$font" "Trabalho SO"
                    fi


             

        else
                    echo    "$name installed"
                    sleep 1
                    clear
                    a=$(pwd)
                    figlet -f $a/"$font" "Trabalho SO"



    fi

    }
    
    #funçao para ver as opcoes de fonts que podemos escolher
    function testarfonts(){

    cd figlet-fonts-master
    a=$(pwd)

    for d in *; do

    if [[ $d == *".flf"* ]]
    then
    echo $d
    figlet -f $a/"$d" "Trabalho SO"
    sleep 1



      fi
       done
}
    
    run
    #testarfonts