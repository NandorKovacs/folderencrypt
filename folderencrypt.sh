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

echo '#!/bin/bash' > $FOLDERNAME.sh
echo "gpg --decrypt $DATA/$FOLDERNAME | tar -xJ" >> $FOLDERNAME.sh
echo 'if [ "$(echo $?)" != 0 ];' >> $FOLDERNAME.sh
echo 'then' >> $FOLDERNAME.sh
echo "        echo \"Error while decrypting. Won't delete encrypted file at $DATA/$FOLDERNAME\"" >> $FOLDERNAME.sh
echo '        exit' >> $FOLDERNAME.sh
echo 'fi' >> $FOLDERNAME.sh
echo "rm -rf $DATA/$FOLDERNAME" >> $FOLDERNAME.sh
echo "rm -rf $FOLDERNAME.sh" >> $FOLDERNAME.sh
chmod u+x $FOLDERNAME.sh
