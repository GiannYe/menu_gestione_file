@echo off

::codice ansi
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"

set "messaggio="
set "ultimoBackup="

:menu
    cls
    echo.

    dir 
    echo.

    echo %ESC%[90m=================%ESC%[92m BACKUP MANAGER %ESC%[90m==================%ESC%[0m
    echo %ESC%[90m= %ESC%[91m1%ESC%[0m. Crea cartella Backup                         %ESC%[90m=%ESC%[0m
    echo %ESC%[90m= %ESC%[91m2%ESC%[0m. Crea cartella                                %ESC%[90m=%ESC%[0m
    echo %ESC%[90m= %ESC%[91m3%ESC%[0m. Copia file in cartella                       %ESC%[90m=%ESC%[0m
    echo %ESC%[90m= %ESC%[91m4%ESC%[0m. Prendi i dati dall'ultima cartella di Backup %ESC%[90m=%ESC%[0m
    echo %ESC%[90m= %ESC%[91m5%ESC%[0m. Numero di file dentro una cartella           %ESC%[90m=%ESC%[0m
    echo %ESC%[90m= %ESC%[91m6%ESC%[0m. Chudi il programma                           %ESC%[90m=%ESC%[0m
    echo %ESC%[90m===================================================%ESC%[0m
    echo.

    echo %ESC%[90m========================%ESC%[92m MESSAGGI %ESC%[90m=========================%ESC%[0m
    echo %ESC%[93m%messaggio%%ESC%[0m
    echo.
    echo %ESC%[93mUltimo Backup: "%ultimoBackup%"%ESC%[0m
    echo %ESC%[90m===========================================================%ESC%[0m
    echo.

    set /p scelta=Cosa vuoi fare? 

    if "%scelta%" == "1" goto creaDirBackup
    if "%scelta%" == "2" goto creaDir
    if "%scelta%" == "3" goto copiaFile
    if "%scelta%" == "4" goto prendiBakup
    if "%scelta%" == "5" goto numFile
    if "%scelta%" == "6" (
        pause
        exit
    )

    set "messaggio=opzione non valida"
goto menu

:creaDirBackup
    ::sostituisce il "/" della data e il ":" dell'ora con i trattini
    ::perche' questi sono caratteri illegali per il nome di un file o directory
    
    ::es:
    :: %date: sostituisci ogni "/" in "-"%
    :: %date: "/" = "-"%
    :: %date: / = -%
    :: %date:/=-%

    set "nome=Backup_%date:/=-%_%time::=-%"

    ::taglia la stringa dal carattere 0 fino al carattere 26
    set "nome=%nome:~0,26%"
    md "%nome%"

    ::%~dp0: percorso in cui stiamo lavorando
    set "ultimoBackup=%nome%"
    set "messaggio=Nuova cartella Backup creata: %nome%"
goto menu

:creaDir
    set /p nome=Inserisci il nome: 
    md "%nome%"

    set "messaggio=Nuova cartella creata: %nome%"
goto menu

:copiaFile
    set /p origine=Inserisci il percorso del file: 
    set /p destinazione=Inserisci la destinazione del file: 

    ::sarebbe meglio robocopy perche' e' piu' veloce e gestisce meglio   
    ::gli errori e mantiene intatti i permessi dei file

    ::/E: copia le sottodirectory, incluse quelle vuote.

    xcopy "%origine%" "%destinazione%" /E

    set "messaggio=%origine% copiato in %destinazione%"
goto menu

:prendiBakup
    set /p destinazione=Inserisci in quale cartella copiare: 

    xcopy "%~dp0%ultimoBackup%" "%~dp0%destinazione%" /E

    set "messaggio=Backup messo in %destinazione%"
goto menu

:numFile
    set /p a=E' la cartella di backup piu' recente (s/n)? 

    if /i "%a%" == "s" (
        if "%ultimoBackup%" == "" (
            set "messaggio=Errore: non esiste una cartella di backup impostata"
            goto menu
        )
        set "cartella=%ultimoBackup%"
    ) else (
        set /p cartella=Inserisci il nome della cartella: 
    )

    ::/R serve per iterare anche i file delle sottodirectory

    ::/a vuol dire aritmetico, quindi riconosce le operazioni
    ::matematiche, guarda i numeri come numeri e in piu'
    ::riconosce i nomi delle variabili senza aver bisogno
    ::delle percentuali

    set /a c=0
    if exist "%~dp0%cartella%" (        
        for /R "%~dp0%cartella%" %%i in (*) do (
            set /a c+=1
        )
        goto ok
    ) else (
        goto nonOk
    )

    ::su batch si puo' stampare %c% solo quando si esce dal if exist
    ::perche' quando esso incontra un istruzione con le parentesi come
    ::l'if esso prepara l'intero blocco in una volta asasegnado alle
    ::variabili il valore che hanno in quel istante

:ok
    set "messaggio=Numero di file dentro %cartella%: %c%"  
goto menu

:nonOk
    set "messaggio=La cartella non esiste"
goto menu 