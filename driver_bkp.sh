#!/usr/bin/env bash
#
# driver_bkp.sh - transferência de arquivos de backup dos servidores para o Google-Drive
#
# E-mail:     liralc@gmail.com
# Autor:      Anderson Lira
# Manutenção: Anderson Lira
#
# ************************************************************************** #
#  Transferência de arquivo de backup.
#
#  Exemplos de execução:
#      $ ./drive_bkp.sh
#
# ************************************************************************** #
# Histórico:
#
#   v1.0 13/04/2022, Anderson Lira:
#       - Início do programa.
#
# ************************************************************************** #
# Testado em:
#   bash 5.0.3
#   Ubuntu 20.1
# ************************************************************************** #

# ======== VARIAVEIS ============================================================== #
export DIA=$(date +%d-%m-%Y-%H:%M:%S)
export DIA_LOG=$(date +%d%m%Y-%H%M%S)
FILE_LOG="/dados/Logs/drive_bkp_$DIA_LOG.log"
IP_SERVER_SAMBA="IPdoSrvSamba"
IP_SERVER_RSYNC="IPSrvLogs"
USER_SERVER_REMOTE="user"
DIR_SERVER_REMOTE="/srv/logs/google-drive"
DIR_LOCAL="/mnt/driver"
DRIVE="/home/user/driver"
# ================================================================================ #

# ======== FUNCOES ================================================================== #
function enviaLog () {
    rsync -az "$FILE_LOG" "$USER_SERVER_REMOTE"@"$IP_SERVER_RSYNC":"$DIR_SERVER_REMOTE"
}

# =================================================================================== #

# ======== TESTES =================================================================== #
ping "$IP_SERVER_SAMBA" -c 4 1> /dev/null  2>&1
if [ "$?" -ne 0 ]
then
    echo "O teste de ping com o IP: $IP_SERVER_SAMBA falhou! - $(date +%H:%M:%S)." >> "$FILE_LOG"
    exit 1
fi

ping "$IP_SERVER_RSYNC" -c 3 1> /dev/null  2>&1
if [ "$?" -ne 0 ]
then
    echo "O teste de ping com o IP: $IP_SERVER_RSYNC falhou! - $(date +%H:%M:%S)." >> "$FILE_LOG"
fi
# ================================================================================ #

# ======== EXECUÇÃO DO PROGRAMA ====================================================== #

# Cabeçalho do log
echo "***********************************************************************" >> "$FILE_LOG"
echo "===================== $DIA ======================" >> "$FILE_LOG"

echo "===> Abrindo compartilhamento via Samba... - $(date +%H:%M:%S)." >> "$FILE_LOG"
mount -t cifs //"$IP_SERVER_SAMBA"/backup01/ "$DIR_LOCAL" -o username=backup,password=password,dir_mode=0777
if [ "$?" -ne 0 ]; then
    echo "-*-*- Houve algum problema ao montar o compartilhamento com o Samba." >> "$FILE_LOG"
    echo "" >> "$FILE_LOG"
    enviaLog
    exit 1
else
    echo "===> Compartilhamento via Samba //$IP_SERVER_SAMBA/backup01/ aberto. - $(date +%H:%M:%S)." >> "$FILE_LOG"
fi

echo "===> Abrindo conexão com o Google-Drive... - $(date +%H:%M:%S)." >> "$FILE_LOG"
su -c "google-drive-ocamlfuse $DRIVE" -s /bin/bash fsf
if [ "$?" -ne 0 ]; then
    echo "-*-*- Houve algum problema ao se conectar ao Google-Driver." >> "$FILE_LOG"
    echo "" >> "$FILE_LOG"
    enviaLog
    exit 1
else
    echo "===> Conectado ao Google-Driver.  - $(date +%H:%M:%S)." >> "$FILE_LOG"
fi

find "$DIR_LOCAL" -maxdepth 2 -name '* *'  -exec bash -c 'TO=$(echo "{}" | sed "s/ /_/g"); FROM=$(echo "{}"); mv "${FROM}" "${TO}"' \;
find "$DIR_LOCAL" -maxdepth 2 -name '*;*'  -exec bash -c 'TO=$(echo "{}" | sed "s/;/-/g"); FROM=$(echo "{}"); mv "${FROM}" "${TO}"' \;
find "$DIR_LOCAL" -maxdepth 2 -name '*(*'  -exec bash -c 'TO=$(echo "{}" | sed "s/(//g"); FROM=$(echo "{}"); mv "${FROM}" "${TO}"' \;
find "$DIR_LOCAL" -maxdepth 2 -name '*)*'  -exec bash -c 'TO=$(echo "{}" | sed "s/)//g"); FROM=$(echo "{}"); mv "${FROM}" "${TO}"' \;

#Iremos fazer uma varredura nos diretórios e arquivos montados via Samba.
for i in $(ls -lh "$DIR_LOCAL" | tr -s ' ' | cut -f 9 -d " " -s); do

    QTDL=$(ls -l "$DIR_LOCAL"/"$i" | wc -l) #Iremos verificar se os diretórios estão vazios ou não.
    QTD=$(("$QTDL"-1))

    if [ "$QTD" -ne 0 ];then
        echo "===> Há $QTD arquivos para backupear no diretório $i." >> "$FILE_LOG"
        echo "===> Abaixo, segue a lista de diretóris e arquivos que serão transferidos para o Google-Driver: " >> "$FILE_LOG"
        #ls -lh "$DIR_LOCAL"/"$i" | tr -s ' ' | cut -f 5,9 -d " " -s >> "$FILE_LOG"
        tree -h "$DIR_LOCAL"/"$i" >> "$FILE_LOG"
        echo "" >> "$FILE_LOG"

        for y in $(ls -lh "$DIR_LOCAL"/"$i" | tr -s ' ' | cut -f 9 -d " " -s); do
            echo "===> Transferindo o arquivo $y para o Google-Driver..." >> "$FILE_LOG"

            DST="$DRIVE"/"$i"
            su -c "ls -lh $DST 1> /dev/null  2>&1" -s /bin/bash fsf
            if [ "$?" -ne 0 ]; then
                su -c "mkdir $DST" -s /bin/bash fsf
                su -c "mv $DIR_LOCAL/$i/$y $DST" -s /bin/bash fsf
                echo "===> Arquivo $y transferido com sucesso para o Google-Driver.  - $(date +%H:%M:%S)." >> "$FILE_LOG"
            else
                su -c "mv $DIR_LOCAL/$i/$y $DST" -s /bin/bash fsf
                echo "===> Arquivo $y transferido com sucesso para o Google-Driver.  - $(date +%H:%M:%S)." >> "$FILE_LOG"
            fi
        done
    else
        echo "===> Não há arquivos para serem backupeados no diretório $i. 
        Verifique se houve a realização de backup desses arquivos. - $(date +%H:%M:%S)." >> "$FILE_LOG"
    fi
done

echo "===> Desconectando do Google-Driver...  - $(date +%H:%M:%S)." >> "$FILE_LOG"
su -c "fusermount -u $DRIVE" -s /bin/bash fsf
if [ "$?" -ne 0 ]; then
    echo "-*-*- Houve algum problema ao desconectar do Google-Driver." >> "$FILE_LOG"
    echo "" >> "$FILE_LOG"
    enviaLog
    exit 1
else
    echo "===> Desconectado do Google-Driver.  - $(date +%H:%M:%S)." >> "$FILE_LOG"
fi

echo "===> Transferência de arquivos do Samba //$IP_SERVER_SAMBA/backup01/ para o Google-Driver concluída!  - $(date +%H:%M:%S)." >> "$FILE_LOG"
echo "===> Desmontando o compartilhamento via Samba...  - $(date +%H:%M:%S)." >> "$FILE_LOG"

umount $DIR_LOCAL
if [ "$?" -ne 0 ]; then
    echo "-*-*- Houve algum problema ao desmontar a partição //$IP_SERVER_SAMBA/backup01/ via Samba." >> "$FILE_LOG"
    echo "" >> "$FILE_LOG"
    enviaLog
    exit 1
else
    echo "===> Fechado o compartilhamento via Samba. - $(date +%H:%M:%S)." >> "$FILE_LOG"
    echo "" >> "$FILE_LOG"
fi

# Rodapé do log
echo "Backup dos arquivos para o Google-Drive realizado com sucesso!
Término do backup realizado em $(date +%d-%m-%Y) às $(date +%H:%M:%S).
" >> "$FILE_LOG"

enviaLog
# ================================================================================ #
