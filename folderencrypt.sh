#!/bin/bash

set -e

trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

FOLDERNAME=$(pwd | grep -Eo [^\/]*$)
DATA=~/.folderencrypt

if test -e $DATA ;
then
	:
else
	mkdir $DATA
fi

cd ..

tar -cJ $FOLDERNAME | gpg --encrypt --recipient nandor1kovacs@gmail.com -o $DATA/$FOLDERNAME
if [ "$(echo $?)" != 0 ];
then
	echo "WARNING! error. Your files wont be encrypted"
	exit
fi

rm -rf $FOLDERNAME

SKRIPTNAME=$FOLDERNAME.folderencrypt.sh

echo '#!/bin/bash' > $SKRIPTNAME
echo "gpg --decrypt $DATA/$FOLDERNAME | tar -xJ" >> $SKRIPTNAME
echo 'if [ "$(echo $?)" != 0 ];' >> $SKRIPTNAME
echo 'then' >> $SKRIPTNAME
echo "        echo \"Error while decrypting. Won't delete encrypted file at $DATA/$FOLDERNAME\"" >> $SKRIPTNAME
echo '        exit' >> $SKRIPTNAME
echo 'fi' >> $SKRIPTNAME
echo "rm -rf $DATA/$FOLDERNAME" >> $SKRIPTNAME
echo "rm -rf $SKRIPTNAME" >> $SKRIPTNAME
chmod u+x $SKRIPTNAME
