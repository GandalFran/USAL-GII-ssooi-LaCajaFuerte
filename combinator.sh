#!/bin/bash
#LA CAJA FUERTE
#	Jaime De La Peña Ramos - i0921486
#	Francisco Pinto Santos - i0918455
#Sistemas Operativos I - Curso 2017/18

###########################################################################################################################################################
###########################################################################################################################################################
###########################################################################################################################################################
#															 +-+-+-+-+-+-+-+-+-+-+																		  #
#															 |C|O|N|S|T|A|N|T|E|S|																		  #
#															 +-+-+-+-+-+-+-+-+-+-+																		  #
#=========================================================================================================================================================#

	#Texto para el menu
	MENU_TEXT="\n\t\e[1;97mJ) JUGAR \e[40m\e[0;32m\n\t\e[1;97mC) CONFIGURACIÓN\e[40m\e[0;32m\n\t\e[1;97mE) ESTADÍSTICAS \e[40m\e[0;32m\n\t\e[1;97mG) GRUPO \e[40m\e[0;32m\n\t\e[1;97mS) SALIR \e[40m\e[0;32m\n\n"
	#Menu de el apartado C)CONFIGURACION
	MENU_CONFIG="\n\t\e[1;97mL) MODIFICAR LONGITUD \e[40m\e[0;97m\n\t\e[1;mR) MODIFICAR RUTA DE FICHERO DE ESTADÍSTICAS \e[40m\e[0;97m\n\t\e[1;mS) SALIR \e[40m\e[0;97m\n\n"
	#Mensaje que sale cuando se invoca la opcion grupos
	GRUPO_MSG="\n\t\t\tGRUPO:\n\n\e[1;97mJaime De La Peña Ramos - \e[1;41;97mi0921486\e[40m\e[0;1;97m - grupo B2\n\n\e[1;97mFrancisco Pinto Santos - \e[1;41mi0918455\e[40m\e[0;1;97m - grupo B2"
	#Minima y maxima longitud permitidas
	MIN_LONGITUD=2
	MAX_LONGITUD=6
	#Ruta del fichero de config.cfg (directorio actual)
	CONFIG_FILE="conf.cfg"
	#Ruta del fichero estadisticas.txt (vacio porque no lo hemos leido de conf.cfg todavia)
	ESTATISTICS_FILE=""
	#Comparacion para ver si hay letras en una variable
	COMP="^[0-9]+$"


###########################################################################################################################################################
###########################################################################################################################################################
###########################################################################################################################################################
# 														+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+														  #
# 														|F|U|N|C|I|O|N|E|S| |A|U|X|I|L|I|A|R|E|S|														  #
#														+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+														  #
#=========================================================================================================================================================#


	#Titulo
	#	Escribe el titulo del programa
	function TITULO
	{
		#Titulo del programa
		 echo -e "\e[96m _                       _          __                 _        "
		 echo -e "| |    __ _    ___ __ _ (_) __ _   / _|_   _  ___ _ __| |_ ___  "
		 echo -e "| |   / _\` |  / __/ _\` || |/ _\` | | |_| | | |/ _ \ '__| __/ _ \ "
		 echo -e "| |__| (_| | | (_| (_| || | (_| | |  _| |_| |  __/ |  | ||  __/ "
		 echo -e "|_____\__,_|  \___\__,_|/ |\__,_| |_|  \__,_|\___|_|   \__\___| "
		 echo -e "                       |__/                                      "
	}

#=========================================================================================================================================================#

	#Pulse para continuar:
	#	Esta funcion imprime el mensaje pulse para continuar y tras ello invoca
	#	read para esperar que el usuario pulse enter para continuar
	function PULSE_PARA_CONTINUAR
	{
		echo -e "\e[1;36m\n\nPulse INTRO para continuar.\e[0m"
		#read -n 1 --> para pulsar cualquier tecla en vez de intro
		read
		echo -e "\n"
	}

#=========================================================================================================================================================#

	#Modificar respuesta:
	#	Esta funcion convierte cuaquier opcion de los menus de jugar o configuracion en minuscula; en mayuscula
	function RESPUESTA_TO_UPPER
	{
		case $RESPUESTA in
			"j")  RESPUESTA="J";;
			"c")  RESPUESTA="C";;
			"e")  RESPUESTA="E";;
			"g")  RESPUESTA="G";;
			"s")  RESPUESTA="S";;
		esac
		case $RESPUESTA_CONFIG in
			"l")  RESPUESTA_CONFIG="L";;
			"r")  RESPUESTA_CONFIG="R";;
			"s")  RESPUESTA_CONFIG="S";;
		esac
	}


###########################################################################################################################################################
###########################################################################################################################################################
###########################################################################################################################################################
#																+-+-+-+-+-+																				  #
#																|J|U|E|G|O|																				  #
#																+-+-+-+-+-+																				  #
#=========================================================================================================================================================#

	#Generar la clave
	#	Esta funcion genera un numero aleatorio sin numeros repetidos
	function GENERATE_KEY
	{
		I=1
		while test $I -le $LONGITUD
		do
			#Recorreremos el vector dando un valor aleatorio entre 0 y 9 a cada posicion
			KEY[$I]=$(($RANDOM%9))

			#Buscamos si el numero esta repetido
			#En el caso de que el numero este repetido, se volveria a generar
			#	porque volveriamos una posicion atras en el vector lo que
			#	compensaria el avanze de la ultima linea del while externo
			J=1
			while test $J -lt $I
			do
				if test ${KEY[$J]} -eq ${KEY[$I]}
				then
					I=$(($I-1))
					J=$I
				fi
				J=$(($J+1))
			done

			#iniciamos el vector de flags a 0 en cada posicion
			FLAG[$I]=0

			#incrementamos I para recorrer el vector
			I=$(($I+1))
		done
	}

#=========================================================================================================================================================#

	#Actualizar la interfaz grafica
	#	Realiza la actualizacion de la interfaz grafica
	function REFRESH_GUI
	{
		#limpiamos la pantalla y mostrarmos el titulo
		clear
		TITULO

		#Mostramos la fecha
		echo -e "\nFecha >> $(date +"%d/%m/%Y")\n"

		#Muestra la tabla de intentos guardada en dicho archivo
		cat gui.temp

		#Calculamos el tiempo que llevamos de partida para imprimirlo
		echo -e "\nTiempo de partida >> $(($SECONDS-$TIEMPO)) s"
		echo -e "Intentos usados   >> $INTENTO"
		echo -e "Longitud          >> $LONGITUD"

		#Se imprimen las cifras acertadas como tales y en las no acertadas se pone un asterisco
		#	Las cifras que han sido acertadas en algun intento aparecen en flags como un 1 y las que no como un 0
		echo -e -n "\n\e[1;36m\nCombinacion >> "
		I=1
		while test $I -le $LONGITUD
		do
			if test ${FLAG[$I]} -eq 1
			then
				echo -n "${KEY[$I]}"
			else
				echo -n "*"
			fi
			I=$(($I+1))
		done 

		#Ponemos una nueva linea y quitamos el color de texto
		echo -e "\n\e[0;32m\n"
	}



#=========================================================================================================================================================#
	function ESTA_REPE
	{
		J=1
		while test $J -lt $I
			do
				if test ${USERKEY[$J]} -eq ${USERKEY[$I]} 
				then
					REPETIDOS=true
				fi
				J=$(($J+1))
			done
	}

#=========================================================================================================================================================#
	
	#Dividir el numero en cifras y meterlas en un vector
	#	Divide el numero de entrada (READ) en cifras y las mete en el vector USERKEY para realizar las operaciones necesarias
	function DIVIDIR_NUMERO_EN_CIFRAS
	{
		#Recorre la combinacion metida por el usuario (en READ) separandola por caracteres y metiendola en userkey
		I=1
		#Para detectar que se no quedan mas cifras en READ comprobamos que el caracter leido es un numero del 0 al 9
		#	en caso de que no sea esto es porque esta vacio, ya que en la introduccion no se permiten otros caracteres
		#	y por tanto no quedan mas cifras por leer
		while [[ $(echo $READ | cut -c $I) =~ $COMP ]]
		do
		   USERKEY[$I]=$(echo $READ | cut -c $I)
		   	#Ahora buscamos si este numero esta repetido -- No terminamos el bucle porque se prima que salga el error
		   	#	de que el numero de digitos introducido no es correcto antes de que los numeros estan repetidos.
			ESTA_REPE
			#Incremetamos I
		   I=$(($I+1))
		done
		#Restamos 1 a I porque usaremos esta variable para saber el numero de digitos introducidos por el usuario
		I=$(($I-1))



	}

#=========================================================================================================================================================#

	#Leer informacion de teclado
	#	Lee la informacion y comprueba que es correcta y divide el numero en sus digitos
	function LEER_INFO
	{
		echo -e -n "\e[1;97mNuevo Intento >> "
		#Usaremos este flag para saber cuando salir
		INFO_CORRECTA=false
		until test $INFO_CORRECTA = true
		do	
			#Usaremos este flag para indicar si hay numeros repetidos en la combinacion
			REPETIDOS=false
			read READ
			#Comprobamos que solo son numeros
			if ! [[ $READ =~ $COMP ]]
			then
				echo -e "\n\e[1;31mERROR: Solo validos numeros, el uso de otro tipo de caracteres esta restringido\e[0m"
				echo -e -n "\n\e[1;97mPrueba otra vez >> "
			else
				#Dividimos el numero en sus cifras
				DIVIDIR_NUMERO_EN_CIFRAS
				#Comprobamos que el numero de cifras introducidas por el usuario es equivalente a la longitud establecida
				if test $I -ne $LONGITUD
				then
					echo -e "\n\e[1;31mERROR : La clave introducida debe ser de longitud $LONGITUD\e[0m"
					echo -e -n "\n\e[1;97mPrueba otra vez >> "
				elif $REPETIDOS = true
				then
					echo -e "\n\e[1;31mERROR : La clave introducida no puede tener numeros reptidos\e[0m"
					echo -e -n "\n\e[1;97mPrueba otra vez >> "
				else
					INFO_CORRECTA=true	
				fi
			fi
		done
	}


#=========================================================================================================================================================#

	#Añadir nuevo intento a gui.temp
	#	Añade el nuevo resultado a la siguiente linea de gui.temp para que en la siguiente ejecucion aparezca en esta
	function ADD_TO_GUI
	{
		#Escribimos intento
		if test $(($INTENTO+1)) -lt 10
		then
			LINEA="\t|00$(($INTENTO+1))| "
		elif test $(($INTENTO+1)) -lt 100
		then
			LINEA="\t|0$(($INTENTO+1))| "
		else
			LINEA="\t|$(($INTENTO+1))| "
		fi
		#Escribimos la combinacion metida por el usuario
		LINEA="$LINEA$READ"
		#Rellenamos los huecos que faltan con guiones
		J=9	#Tamaño del campo en la tabla
		I=$LONGITUD
		while test $I -lt $J
		do
			LINEA="$LINEA-"
			I=$(($I +1))
		done
		LINEA="$LINEA|"
		echo -e $LINEA >> gui.temp

		#Escribimos los estados; que pueden ser A de acierto, F de fallo y S de semiacierto
		LINEA="\t|---| "
		I=1
		while test $I -le $LONGITUD
		do
			LINEA="$LINEA${ESTADOS[$I]}"
			I=$(($I +1))
		done
		#Rellenamos los huecos que faltan con guiones
		J=9 #Tamaño del campo en la tabla
		I=$LONGITUD
		while test $I -lt $J
		do
			LINEA="$LINEA-"
			I=$(($I +1))
		done
		#Añadimos un separador
		LINEA="$LINEA|"
		#Lo metemos en gui.temp y añadimos un separador
		echo -e $LINEA >> gui.temp
		echo -e "\t+---+----------+" >> gui.temp 
	}

#=========================================================================================================================================================#

	#Generar vector de estados ASF
	#	Segun los valores de el vector USERKEY, pone A, S o F segun se especifica en el enunciado del ejercicio
	function GENERAR_VECTOR_ESTADOS
	{
		I=1
		while test $I -le $LONGITUD
		do
			#Si el numero es igual, hay un acierto
			if test ${USERKEY[$I]} -eq ${KEY[$I]}
			then
				ESTADOS[$I]="A"
				FLAG[$I]=1
			else #En otro caso comenzamos por ponerlo como fallo y en el caso de que encontremos que es semiacierto, ponemos una S
				ESTADOS[$I]="F"
				J=1
				#Recorremos el vector, y si el numero buscado esta; pero no en la posicion adecuada, enconces se pone semiacierto
				while test $J -le $LONGITUD
				do
					if test ${USERKEY[$I]} -eq ${KEY[$J]}
					then
						ESTADOS[$I]="S"
						#Terminamos el bucle
						J=$LONGITUD
					fi
					#incrementamos el indice J (para recorrer buscando semiaciertos)
					J=$(($J + 1))
				done
			fi
			#incrementamos el indice I (para recorrer el vector de una vez)
			I=$(($I + 1))
		done 
	}

#=========================================================================================================================================================#

	#Comprobar que se han acertado todos los numeros
	#	Con esta funcion comprobamos si se ha acertado la clave (si en ESTADOS es todo A); en cuyo caso se sale poniendo TERMINAR a true
	function COMPROBACION_SALIDA
	{
		TERMINAR=true
		I=1
		while test $I -le $LONGITUD
		do
			if test ${ESTADOS[$I]} != "A"
			then
				#Se pone terminar a false si encontramos un numero que no es un acierto
				TERMINAR=false
				#Acabamos el bucle
				I=$LONGITUD
			fi
			#incrementamos la variable i para recorrer el bucle
			I=$(($I+1))
		done
	}

#=========================================================================================================================================================#

	#JUEGO
	#	funcion principal de juego
	function JUEGO 
	{
		#VECTORES QUE USAREMOS PARA DESAROLLAR EL JUEGO
		declare -a KEY		#Vector con la clave
		declare -a FLAG		#Vector con flags para mostrar el numero
		declare -a USERKEY 	#Vector con la clave metida por el usuario en cada intento
		declare -a ESTADOS 	#Estado del numero --> ACIERTO - SEMIACIERTO - ERROR

		#GENERAR CLAVE
		GENERATE_KEY

		#PREPARAMOS LA INTERFAZ--> se guarda en gui.temp; el cual se elemina tras cada intento
		#Eliminamos gui.temp si existe para evitar partidas corruptas
		if test -a gui.temp
			then
			rm gui.temp
		fi
		echo -e "\t+---+----------+" >> gui.temp
		echo -e "\t| I |  NUMERO  |" >> gui.temp
		echo -e "\t|   |  ESTADO  |" >> gui.temp
		echo -e "\t+---+----------+" >> gui.temp

		#DAMOS VALORES INICIALES
		TERMINAR=false
		INTENTO=0

		#COMENZAR CONTADOR
		TIEMPO=$SECONDS

		#COMIENZA EL JUEGO
		until test $TERMINAR = true
		do
			#ACTUALIZAR LA INTERFAZ
			REFRESH_GUI

			#PEDIR INFO + DIVIDIR NUMERO EN CIFRAS
			LEER_INFO
				
			#GENERAR VECTOR DE ESTADOS + GUARDARLO EN GUI.TEMP
			GENERAR_VECTOR_ESTADOS
			ADD_TO_GUI

			#COMPROBAR SI SE PUEDE SALIR
			COMPROBACION_SALIDA

			#ICREMENTAMOS INTENTO
			INTENTO=$(($INTENTO+1))
		done

		#SE INDICA QUE SE HA ACERTADO
		echo -e "\e[1;46m\"Ha abierto la caja fuerte\"\e[97m\e[0;1;97m"
		echo -e "\tPID       >>>  $$"
		echo -e "\tFECHA     >>>  $(date +"%d/%m/%Y")"
		echo -e "\tHORA      >>>  $(date +"%H:%M:%S")"
		echo -e "\tINTENTOS  >>>  $INTENTO"
		echo -e "\tTIEMPO    >>>  $(($SECONDS-$TIEMPO)) s"
		echo -e "\tLONGITUD  >>>  $LONGITUD"
		echo -e "\tCLAVE     >>>  $READ\e[0m"
		#AÑADIMOS A ESTADISTICAS LOS DATOS DE LA PARTIDA
		if ! [[ -w $ESTATISTICS_FILE ]] && [[ -a $ESTATISTICS_FILE ]];
	    then
	    	echo -e "\n\e[1;31mERROR: No se han guardado los datos de la partida en $ESTATISTICS_FILE por falta de permisos\e[0m"
	    	SALIR=true
		elif ! [[ -s $ESTATISTICS_FILE ]];	#si esta vacio NO ponemos \n, porque nos dara error en la lectura
		then
			echo -e -n "|$$|$(date +"%d/%m/%Y")|$(date +"%H:%M:%S")|$INTENTO|$(($SECONDS-$TIEMPO))|$LONGITUD|$READ|" > $ESTATISTICS_FILE
		else
			echo -e -n "\n|$$|$(date +"%d/%m/%Y")|$(date +"%H:%M:%S")|$INTENTO|$(($SECONDS-$TIEMPO))|$LONGITUD|$READ|" >> $ESTATISTICS_FILE
		fi
		#ELIMINAMOS FICHERO TEMPORAL DE INTERFAZ GRAFICA
		rm gui.temp	
	}

###########################################################################################################################################################
###########################################################################################################################################################
###########################################################################################################################################################
# 														  +-+-+-+-+-+-+-+-+-+-+-+-+-+																	  #
# 														  |C|O|N|F|I|G|U|R|A|C|I|O|N|																	  #
#														  +-+-+-+-+-+-+-+-+-+-+-+-+-+																	  #
#=========================================================================================================================================================#

	#Cambiar ruta de estadísticas:
		#Esta funcion lee la ruta de estadísticas, comprobando que esta existe y que tenga permisos. 
		#Si no hay permisos, se mostrará el mensaje que lo avise y no dejará realizar otra acción hasta que se introduzca una ruta válida.
	
	function CAMBIAR_RUTA_ESTADISTICAS
	{
		echo -e -n "\n\e[1;97mIntroduzca nueva ruta >> \e[0m"
		read NEW_ESTATISTICS_FILE

		NEW_ESTATISTICS_FILE_PATH=$(dirname $NEW_ESTATISTICS_FILE) #dirname proporciona solo la seccion de directorio suprimiendo el nombre del archivo

		if ! [[ -d $NEW_ESTATISTICS_FILE_PATH ]];
		then
			echo -e "\n\e[1;31mERROR: No se encontro la ruta o no se tienen los permisos\e[0m"
			PULSE_PARA_CONTINUAR
		elif ! [[ $NEW_ESTATISTICS_FILE =~ ".txt" ]]
		then
			echo -e "\n\e[1;31mERROR: No ha introducido un archivo con extension .txt\e[0m"
			PULSE_PARA_CONTINUAR
		elif  ! [[ -r $NEW_ESTATISTICS_FILE ]] || ! [[ -w $NEW_ESTATISTICS_FILE ]] &&  [[ -a $NEW_ESTATISTICS_FILE ]];
		then
			echo -e "\n\e[1;31mERROR: No se tienen los permisos necesarios sobre $ESTATISTICS_FILE \e[0m"
			PULSE_PARA_CONTINUAR
		else
			ESTATISTICS_FILE=$NEW_ESTATISTICS_FILE
			echo -e "LONGITUD=$LONGITUD\nESTADISTICAS=$ESTATISTICS_FILE" > $CONFIG_FILE
		fi
	}

#=========================================================================================================================================================#
	
	#Cambiar Longitud:
	#	Esta funcion cambiar la longitud de la clave por otra que introduzca el usuario
	
	function CAMBIAR_LONGITUD
	{
		echo -e -n "\n\e[1;97mIntroduzca nueva longitud >> \e[0m"
		read LEER_LONGITUD
		#Comprobamos que solo son numeros
		if ! [[ $LEER_LONGITUD =~ $COMP ]];
		then
			echo -e "\n\e[1;31mERROR: solo son validos numeros, el uso de otro tipo de caracteres esta restringido\e[0m"
			PULSE_PARA_CONTINUAR
		#comprobamos que los valores esten en el rango permitido
		elif test $LEER_LONGITUD -lt $MIN_LONGITUD -o $LEER_LONGITUD -gt $MAX_LONGITUD
		then
			echo -e "\n\e[1;31mERROR: Introduzca un numero en el rango ($MIN_LONGITUD-$MAX_LONGITUD)\e[0m"
			PULSE_PARA_CONTINUAR
		else
			LONGITUD=$LEER_LONGITUD
			echo -e "LONGITUD=$LONGITUD\nESTADISTICAS=$ESTATISTICS_FILE" > $CONFIG_FILE
		fi
	}

#=========================================================================================================================================================#

	function CONFIG
	{                       

		SALIR_CONFIG=false
				
		#SE PIDE LA INTRODUCCION DE UN VALOR Y SE ACTUA EN CONSECUENCIA
		until test $SALIR_CONFIG = true
		do
			#ESCRIBIMOS EL MENU
			clear
			TITULO
			echo -e "\n\n\t>Longitud: \e[1;41;97m$LONGITUD\e[40m\e[0m"
			echo -e "\n\t\e[1;96m>Ruta Fichero Estadisticas: \e[1;41;97m$ESTATISTICS_FILE\e[40m\e[0;32m"
			echo -e $MENU_CONFIG
			echo -n -e "\e[1;96mIntroduzca una opcion >> "
			read RESPUESTA_CONFIG

			#SI RECIBIMOS l, r ó s SE PASAN L, R ó S respectivamente
			RESPUESTA_TO_UPPER

			case $RESPUESTA_CONFIG in
				"L") #LONGITUD: Nos lleva a cambiar la longitud de la clave
					CAMBIAR_LONGITUD
					;;
				"R") #RUTA DE ESTADÍSTICAS: Nos permite cambiar la ruta de estadisticas
					CAMBIAR_RUTA_ESTADISTICAS
					;;
				"S") #SALIR: salir del juego
					SALIR_CONFIG=true
					;;
				*) #DEFAULT
					echo -e -n "\n\e[1;31mERROR: Introduzca un caracter valido\e[0m"
					PULSE_PARA_CONTINUAR
					;;
			esac
		done
	}

###########################################################################################################################################################
###########################################################################################################################################################
###########################################################################################################################################################
# 															+-+-+-+-+-+-+-+-+-+-+-+-+																	  #
# 															|E|S|T|A|D|I|S|T|I|C|A|S|																	  #
#														 	+-+-+-+-+-+-+-+-+-+-+-+-+																	  #
#=========================================================================================================================================================#

	function ESTADISTICAS
	{
		clear
		TITULO

		#En el caso de que haya jugadas hacemos los calculos
		if ! [[ -s $ESTATISTICS_FILE ]] || ! [[ -r $ESTATISTICS_FILE ]] ;
		then
				echo -e -n "\nNo se tienen registros de estadisticas todavia"
		else
			#Calculo el numero de jugadas
			NUM_JUGADAS=$(($(wc -l < $ESTATISTICS_FILE)+1))

			#Ponemos a 0 las medias de longitudes y tiempos y el tiempo total
			T_INVERTIDO=0
			M_LONG=0

			#Inicializamos los valores de las jugadas especiales con la primera linea de stadisticas.txt
			declare -a JCORTA		#Jugada mas corta
			declare -a JLARGA		#Jugada mas larga
			declare -a MIN_I_MAX_L	#Jugada de menos intentos y mas longitud
			declare -a MIN_I_MIN_L	#Jugada de menos intentos y menos longitud

			JCORTA[1]=$(head -1 $ESTATISTICS_FILE | cut -f 6 -d "|" )	#Tiempo
			JCORTA[2]=$(head -1 $ESTATISTICS_FILE)						#Informacion sobre la jugada

			JLARGA[1]=$(head -1 $ESTATISTICS_FILE | cut -f 6 -d "|" )	#Tiempo
			JLARGA[2]=$(head -1 $ESTATISTICS_FILE)						#Informacion sobre la jugada

			MIN_I_MAX_L[1]=$(head -1 $ESTATISTICS_FILE | cut -f 5 -d "|" )	#Intentos
			MIN_I_MAX_L[2]=$(head -1 $ESTATISTICS_FILE | cut -f 7 -d "|" )  #Longitud
			MIN_I_MAX_L[3]=$(head -1 $ESTATISTICS_FILE)						#Informacion sobre la jugada

			MIN_I_MIN_L[1]=$(head -1 $ESTATISTICS_FILE | cut -f 5 -d "|" )	#Intentos
			MIN_I_MIN_L[2]=$(head -1 $ESTATISTICS_FILE | cut -f 7 -d "|" )  #Longitud
			MIN_I_MIN_L[3]=$(head -1 $ESTATISTICS_FILE)						#Informacion sobre la jugada

			#Comenzamos el bucle
			for line in $(cat $ESTATISTICS_FILE)
			do 
				#Separamos la linea en variables
				PIDE=$( echo $line      | cut -f 2 -d "|")	#se empieza en 2 porque el primer caracter es el \n para cambiar de linea
				FECHAE=$( echo $line    | cut -f 3 -d "|")
				HORAE=$( echo $line     | cut -f 4 -d "|")
				INTENTOSE=$( echo $line | cut -f 5 -d "|")
				TIEMPOE=$( echo $line   | cut -f 6 -d "|")
				LONGITUDE=$( echo $line | cut -f 7 -d "|")
				CLAVEE=$( echo $line    | cut -f 8 -d "|")

				#Parte de las jugadas generales
				T_INVERTIDO=$(($T_INVERTIDO+$TIEMPOE))
				M_LONG=$(($M_LONG+$LONGITUDE))

				#Parte de las jugadas especiales
				#Jugada mas corta
					if test $TIEMPOE -lt ${JCORTA[1]}
					then
						JCORTA[1]=$TIEMPOE	#Tiempo
						JCORTA[2]=$line		#Informacion de la linea
					fi
				#Jugada mas larga
					if test $TIEMPOE -gt ${JLARGA[1]}
					then
						JLARGA[1]=$TIEMPOE	#Tiempo
						JLARGA[2]=$line 	#Informacion de la linea
					fi
				#Jugadas de maxima longitud y minimos intentos
					if test $LONGITUDE -gt ${MIN_I_MAX_L[2]}
					then
						MIN_I_MAX_L[1]=$INTENTOSE  #Intentos
						MIN_I_MAX_L[2]=$LONGITUDE  #Longitud
						MIN_I_MAX_L[3]=$line	   #Informacion sobre la jugada
					#Si la longitud es igual y tiene menos intentos la guardamos
					elif test $LONGITUDE -eq ${MIN_I_MAX_L[2]} -a $INTENTOSE -lt ${MIN_I_MAX_L[1]}
					then
						MIN_I_MAX_L[1]=$INTENTOSE  #Intentos
						MIN_I_MAX_L[2]=$LONGITUDE  #Longitud
						MIN_I_MAX_L[3]=$line	   #Informacion sobre la jugada
					fi
				#Jugadas de minima longitud y minimos intentos
					if test $LONGITUDE -lt ${MIN_I_MIN_L[2]}
					then
						MIN_I_MIN_L[1]=$INTENTOSE  #Intentos
						MIN_I_MIN_L[2]=$LONGITUDE  #Longitud
						MIN_I_MIN_L[3]=$line	   #Informacion sobre la jugada
					#Si la longitud es igual y tiene menos intentos la guardamos
					elif test $LONGITUDE -eq ${MIN_I_MIN_L[2]} -a $INTENTOSE -lt ${MIN_I_MIN_L[1]}
					then
						MIN_I_MIN_L[1]=$INTENTOSE  #Intentos
						MIN_I_MIN_L[2]=$LONGITUDE  #Longitud
						MIN_I_MIN_L[3]=$line	   #Informacion sobre la jugada
					fi


				done

				#Hallamos las medias de longitudes y tiempos
				M_TIEMPOS=$(( $T_INVERTIDO/$NUM_JUGADAS ))
				M_LONG=$(($M_LONG/$NUM_JUGADAS))

				#Sacamos las estadisticas generales
				echo -e "\nESTADISTICAS GENERALES: \n"
				echo -e "\t\e[1;97mNumero de jugadas   >> $NUM_JUGADAS"
				echo -e "\tMedia de longitudes >> $M_LONG"
				echo -e "\tMedia de tiempos    >> ${M_TIEMPOS}s"
				echo -e "\tTiempo invertido    >> ${T_INVERTIDO}s\e[0;1;96m"
				#Sacamos las estadisticas especificas
				echo -e "\nESTADISTICAS ESPECIFICAS:\e[1;97m |PID|FECHA|HORA|INTENTOS|TIEMPO|LONGITUD|CLAVE|"
				echo -e "\n\tJugada mas corta >> \e[1;41m${JCORTA[1]} s\e[0;1;97m \n\t\t>> ${JCORTA[2]} << "
				echo -e "\n\tJugada mas larga >> \e[1;41m${JLARGA[1]} s\e[0;1;97m \n\t\t>> ${JLARGA[2]} << "
				echo -e "\n\tJugada de menos intentos con longitud mas larga >> \e[1;41m${MIN_I_MAX_L[1]} INT y ${MIN_I_MAX_L[2]} LONG\e[0;1;97m \n\t\t>> ${MIN_I_MAX_L[3]} <<"
				echo -e "\n\tJugada de menos intentos con longitud mas corta >> \e[1;41m${MIN_I_MIN_L[1]} INT y ${MIN_I_MIN_L[2]} LONG\e[0;1;97m \n\t\t>> ${MIN_I_MIN_L[3]} << \e[0m"
			fi

	}

###########################################################################################################################################################
###########################################################################################################################################################
###########################################################################################################################################################
# 																+-+-+-+-+-+																				  #
# 																|S|E|T|U|P|																				  #
#																+-+-+-+-+-+																				  #
#=========================================================================================================================================================#
	#Realiza las tareas de antes de iniciar a jugar
	#	1 - leer (si hay) argumentos
	#	2 - cargar config.cfg (si existe) y comprobar que los datos que contiene son correctos
	#	3 - cargar estadisticas.txt (si existe) y en caso de no existir, crearlo

		#Lectura de argumentos de terminal
		#	Lee los argumentos y comprueba que son correctos
		function LECTURA_ARGUMENTOS
		{
			if [[ $3 -ne 2 ]] || [[ $1 != "-l" ]] || ! [[ $2 =~ $COMP ]];
			then #Comprobamos que solo hay 2 argumentos <-l y longitud> y que el primero es -l y el segundo es un numero entero
				ERROR=true
				echo -e "\n\e[1;31mERROR: uso del programa ./combinator.sh [-l longitud]\e[0m\n"
			elif test $2 -lt $MIN_LONGITUD -o $2 -gt $MAX_LONGITUD
			then #Comprobamos que la longitud esta entre los parametros permitidos
				ERROR=true
				echo -e "\n\e[1;31mERROR: longitud permitida ($MIN_LONGITUD-$MAX_LONGITUD)\e[0m\n"
			else #Si se verifica todo esto ponemos la longitud a el tamaño pasado por argumentos
				ERROR=false
				LONGITUD=$2
			fi

		}

#=========================================================================================================================================================#

		#CARGA DE LA CONFIGURACION + COMPROBACION DE QUE LA CONFIGURACION ES CORRECTA
		#	Esta funcion lee los datos de config.cfg
		function LOAD_CONFIG
		{
			#comprobamos que config.cfg existe y tenemos permisos de lectura
			if test -r $CONFIG_FILE
			then #si podemos leer, mediante filtros obtenemos la longitud y la ruta del fichero de estadisticas
				ERROR=false
				LONGITUD_TEMP=$(grep "^LONGITUD=" < $CONFIG_FILE |cut -f 2 -d "="| tr -d "\r" )
				ESTATISTICS_FILE=$(grep "^ESTADISTICAS=" < $CONFIG_FILE | cut -f 2 -d "=")
			else #si no podemos leer, lo indicamos y marcamos error como true
				ERROR=true
				LONGITUD_TEMP=$MIN_LONGITUD #Para que no haya problemas en las comparaciones posteriores si se da este error
				echo -e "\n\e[1;31mERROR: no se encontro el fichero config.cfg o no se tienen permisos de necesarios.\e[0m\n" 
			fi

			if ! [[ -r $ESTATISTICS_FILE ]] || ! [[ -w $ESTATISTICS_FILE ]] &&  [[ -a $ESTATISTICS_FILE ]]
			then 
				ERROR=true
				echo -e "\n\e[1;31mERROR: no se encontro el fichero $ESTATISTICS_FILE o no se tienen permisos necesarios.\e[0m\n" 
			fi
			#Compobamos que la longitud es correcta en el caso de que no haya habido errores al leerla
			#	Comprobamos que la longitud son solo numeros
			if test $ERROR = false
			then
				if ! [[ $LONGITUD_TEMP =~ $COMP ]] ;
				then
					ERROR=true
					echo -e "\n\e[1;31mERROR: Los caracteres permitdos en el campo \"LONGITUD\" de $CONFIG_FILE estan restringidos.\e[0m\n"
				#	Comprobamos que esta en los erores esperados
				elif [ $LONGITUD_TEMP -lt $MIN_LONGITUD ] || [ $LONGITUD_TEMP -gt $MAX_LONGITUD ] ;
				then
					ERROR=true
					echo -e "\n\e[1;31mERROR: El campo \"LONGITUD\" de $CONFIG_FILE esta restringido al rango ($MIN_LONGITUD-$MAX_LONGITUD).\e[0m\n"
				elif test $LONGITUD -eq 0
				then
					ERROR=false
					LONGITUD=$LONGITUD_TEMP
				fi
			fi
		}

###########################################################################################################################################################
###########################################################################################################################################################
###########################################################################################################################################################
# 													+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+																	  # 
# 													|F|U|N|C|I|O|N| |P|R|I|N|C|I|P|A|L|																	  # 
# 													+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+																	  # 
#=========================================================================================================================================================#
		#Muestra el menu y permite elegir una opcion. Tras lo cual redirecciona a la funcion correspondiente

		#REALIZAMOS LAS TAREAS PREVIAS ANTES DE COMENZAR EL JUEGO
			#DAR VALORES INICIALES
			LONGITUD=0
			ERROR=false

			#SI HAY ARGUMENTOS SE LEEN Y SE CORROBORA QUE SON CORRECTOS
			if test $# -ge 1
			then 
				LECTURA_ARGUMENTOS $1 $2 $#
			fi

			#SI NO HA HABIDO ERRORES EN EL PROCESO ANTERIOR SE CARGAN LOS DATOS DE confg.cfg: 
			if test $ERROR = false
			then
				LOAD_CONFIG
			fi

			#SE INICIALIZAR SALIR CON EL VALOR DE ERROR, YA QUE SI ERROR=true ENTONCES SALIR=true, Y NO SE ENTRARIA A JUGAR
			SALIR=$ERROR
				
			#SE MUESTRA EL MENU, SE PIDE LA INTRODUCCION DE UN VALOR Y SE ACTUA EN CONSECUENCIA
			until test $SALIR = true
			do
				#ESCRIBIMOS EL MENU
				clear
				TITULO

				echo -e $MENU_TEXT
				echo -n -e "\t\e[1;96m\"La Caja Fuerte\". Introduzca una opción >> "
				read RESPUESTA

				#SI RECIBIMOS j,c,e,g o s, SE PASAN A J,C,E,G o S respectivamente
				RESPUESTA_TO_UPPER

				case $RESPUESTA in
					"J") #JUGAR: Nos lleva a realizar una partida
						JUEGO
						PULSE_PARA_CONTINUAR
						;;
					"C") #CONFIGURACION: Nos muestra la configuracion y nos permite cambiarla
						CONFIG
						PULSE_PARA_CONTINUAR
						;;
					"E") #ESTADISTICAS: Nos muestra las estadisticas del juego
						ESTADISTICAS
						PULSE_PARA_CONTINUAR
						;;
					"G") #GRUPO: imiprime nombre y usuario de los integrantes del grupo
						clear
						TITULO
						echo -e $GRUPO_MSG
						PULSE_PARA_CONTINUAR
						;;
					"S") #SALIR: salir del juego
						SALIR=true
						PULSE_PARA_CONTINUAR
						clear
						;;
					*) #DEFAULT
						echo -e "\n\e[1;31mERROR: Introduzca un caracter valido\e[0m"
						PULSE_PARA_CONTINUAR
						;;
				esac
			done
