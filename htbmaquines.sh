#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
    echo -e "\n\n[+]Saliendo... "
    tput cnorm && exit 1
}

#Ctrl_c
trap ctrl_c INT

#Variables Globales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
  echo -e "\n${redColour}[+]${endColour} ${grayColour}Uso:${endColour}"
  echo -e "\t${redColour}u)${endColour} ${grayColour} Descargar o actualizar archivos necesarios${endColour}"
  echo -e "\t${redColour}i)${endColour} ${grayColour} Buscar por direccion IP${endColour}"
  echo -e "\t${redColour}m)${endColour} ${grayColour} Buscar por nombre de la màquina"${endColour}
  echo -e "\t${redColour}y)${endColour} ${grayColour} Buscar por link de Youtube"${endColour}
  echo -e "\t${redColour}d)${endColour} ${grayColour} Buscar por dificultad de la màquina"${endColour}
  echo -e "\t${redColour}o)${endColour} ${grayColour} Buscar por sistema operativo"${endColour}
  echo -e "\t${redColour}h)${endColour} ${grayColour} Muestra este panel de ayuda para el usuario${endColour}"

}

function searchMachine(){
  machineName="$1"
  
  machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | awk '{printf "\033[34m%s\033[0m", $1;
                                                                  for (i = 2; i <= NF; i++) {
                                                                     printf " %s", $i;
                                                                  }
                                                                printf "\n";}' | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//')"
if [[ "$machineName_checker" ]]; then 

  echo -e "${yellowColour}[+] ${endColour} ${grayColour}Listando todas las propiedades de la màquina${endColour}${blueColour} $machineName: ${endColour}\n"
  sleep 2
  cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | awk '{printf "\033[34m%s\033[0m", $1; for (i = 2; i <= NF; i++) {
                                                                     printf " %s", $i;
                                                                  }
                                                                printf "\n";}' | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//'
else
  echo -e "\n ${redColour}[¡] Màquina no encontrada${endColour}"
fi
}

function updateFiles(){
  if [ ! -f bundle.js ]; then
    tput civis
    echo -e "${yellowColour}[+]${endColour} ${grayColour}Descargando los archivos necesarios${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "${yellowColour}[+]${endColour} ${grayColour}Todos los archivos se han descargado${endColour}"
    tput cnorm
  else
    tput civis
    echo -e "${yellowColour}[+]${endColour} ${grayColour}Comprobando si hay actualizaciones...${endColour}"
    sleep 2
    curl -s $main_url > bundle_temp.js 
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print 1}')
    md5_original_value=$(md5sum bundle.js | awk '{print 1}')

    if [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${blueColour} No se han detectado actualizaciones${endColour}"
      rm bundle_temp.js
    else
      echo -e "\n${yellowColour}[+]${endColour}${redColour} Se han detectado actualizaciones disponibles${endColour}"
      rm bundle.js && mv bundle_temp.js bundle.js
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Todos los archivos han sido actualizados${endColour}"
    fi

    tput cnorm
  fi
}

function searchIP(){
  ipAddress="$1"
  machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print$NF} ' | tr -d '"' | tr -d ',')"

if [[ "$machineName" ]]; then
  echo -e "\n ${yellowColour} [+] ${endColour} ${grayColour}La maquina correspondiente a la direcciòn${endColour}${blueColour} $ipAddress ${endColour}${grayColour}es${endColour}${redColour} $machineName${endColour}\n"
else
  echo -e "\n ${redColour}[!] La direcciòn IP proporcionada no corresponde a ninguna màquina registrada${endColour}"
fi

}

function getYoutubeLink(){
  machineName="$1"
  youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep "youtube: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

if [[ "$youtubeLink" ]]; then
  echo -e "\n ${yellowColour}[+]${endColour} ${grayColour}El tutorial para la màquina se encuentra en el siguiente enlace, que lo disfrutes:${endColour} ${blueColour}$youtubeLink${endColour}"
else
  echo -e "\n ${redColour}[!] La màquina proporcionada no existe ${endColour}"
fi
}

function getMachinesDifficulty(){
  difficulty="$1"
  
  difficulty_check="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | tr -d '"' | tr -d ',' | awk 'NF{print $NF}' | column)"
if [[ "$difficulty_check" ]]; then
  echo -e " ${yellowColour}[+]${endColour} ${grayColour}Representando las màquinas con la dificultad${endColour} ${blueColour}$difficulty${endColour}${grayColour}:${endColour}  \n"
  cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | tr -d '"' | tr -d ',' | awk 'NF{print $NF}' | column
else
 echo -e "\n ${redColour}[!] La dificultad que proporcionaste no existe${endColour}"
fi
}

function getOSMachines(){
  os="$1"

  os_checker="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | tr -d '"' | tr -d ',' | awk 'NF{print $NF}' | column)"

  if [[ "$os_checker" ]]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Representando las màquinas${endColour} ${redColour}$os${endColour}${grayColour}:${endColour}\n"
    cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | tr -d '"' | tr -d ',' | awk 'NF{print $NF}' | column
  else
    echo -e "\n ${redColour}[!] El sistema operativo que proporcionaste no se encuentra${endColour}\n"
  fi

}

function getOSDifficultyMachines(){
  difficulty="$1"
  os="$2"
  
  check_results="$(cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | tr -d '"' | tr -d ',' | awk 'NF{print $NF}' | column)"

if [[ "$check_results" ]]; then
  echo -e "\n ${yellowColour}[+]${endColour} ${grayColour}Representando las màquinas con la dificultad${endColour} ${redColour}$difficulty${endColour} ${grayColour}y el sistema operativo${endColour} ${greenColour}$os${endColour}${grayColour}:${endColour} \n"
  cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | tr -d '"' | tr -d ',' | awk 'NF{print $NF}' | column
else
  echo -e "\n ${redColour}[!] El sistema operativo o la dificultad que proporcionaste no coinciden con los registros${endColour}"
fi

}

function getSkills(){
  skills="$1"

  skill_check="$(cat bundle.js | grep "skills: " -B 6 | grep "$skills " -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d ',' | tr -d '"' | column)"

if [[ "$skill_check" ]]; then
  echo -e "\n ${yellowColour}[+]${endColour} ${grayColour}Estas son las màquinas en las que se trata la Skill${endColour}${greenColour} $skills${endColour}${grayColour}:${endColour}\n"
  cat bundle.js | grep "skills: " -B 6 | grep "$skills " -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d ',' | tr -d '"' | column
else
  echo -e "\n ${redColour}[!] Disculpame pero la Skill que solicitas no existe o no està registrada${endColour}\n"
fi
}

#Indicadores
declare -i parameter_counter=0

#Adds
declare -i add_difficulty=0
declare -i add_os=0


while getopts "m:ui:y:d:o:s:h" arg; do 
  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG"; let add_difficulty+=1; let parameter_counter+=5;;
    o) os="$OPTARG"; let add_os+=1; let parameter_counter+=6;;
    s) skills="$OPTARG"; let parameter_counter+=7;;
    h) ;; 
  esac 
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName

elif [ $parameter_counter -eq 2 ]; then
  updateFiles

elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAddress

elif [ $parameter_counter -eq 4 ]; then
  getYoutubeLink $machineName

elif [ $parameter_counter -eq 5 ]; then
  getMachinesDifficulty $difficulty

elif [ $parameter_counter -eq 6 ]; then
  getOSMachines $os

elif [ $parameter_counter -eq 7 ]; then
  getSkills "$skills"

elif [ $add_difficulty -eq 1 ] && [ $add_os -eq 1 ]; then
  getOSDifficultyMachines $difficulty $os

else
  helpPanel

fi
