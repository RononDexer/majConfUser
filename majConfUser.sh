#!/bin/bash
#ce script doit être mis dans /home/votrenom/ le reste est pris en charge par le script
#vous pouvez adapter ce script à un autre github facilement
#L'intérêt de ce script est de mettre à jour la config utilisateur(les dossiers dans /home/) de plusieurs machines si elles ont accès au réseau
#etape 1 : verif si besoin de mise à jour
cd ~/.majConfUser;
versActuelle=$(cat version.txt);
rm -R tmp; mkdir tmp; cd tmp;
wget https://raw.github.com/RononDexer/majConfUser/master/version.txt;
versProchaine=$(cat version.txt);
cd ~/.majConfUser; 
if [ $versActuelle -lt $versProchaine ] ; then
  rm -R -f majConfUser; git clone https://github.com/RononDexer/majConfUser;
  cd majConfUser;
  applications=" ";
  for fic in *.info ; do
    if [ $(head -1 $fic) -gt $versActuelle ];then
      applications="$applications $(head -2 $fic | tail -1)";
    fi
  done
  if zenity --question --text="Des mises à jour de configuration sont disponibles pour $applications. Voulez-vous mettre à jour? Si oui, avant merci de fermer les applications concernées si possible."; then
    echo "Début des mises à jour";
    #calcul nombre maj a faire 
    (
    #nbMaj=$(ls *.tar.gz | wc -l);
    nbMaj=$(($versProchaine-$versActuelle));
    cpteur=0;
    currentMaj=" ";
    nbCurrentMaj=$(($versActuelle+1));
    while [ $cpteur -lt $nbMaj ]; do
        for fic in *.info;do
            if [ $(head -1 $fic) -eq $nbCurrentMaj ];then
                currentMaj=$fic;
            fi
        done
        oIFS=$IFS;
        IFS=".";
        set $fic;
        nameFic=$1;
        IFS=$oIFS;
        echo untar $nameFic;
        tar xzfv $nameFic.tar.gz;
        cd $nameFic && cp -R . ~;
        cd ~/.majConfUser/majConfUser/;
        rm $nameFic.info;
        rm $nameFic.tar.gz;
        let cpteur++ 1;
        progress=$(($(($cpteur*100))/$nbMaj));
        echo $progress; sleep 1;
    done
    cd ~/.majConfUser;
    cp tmp/version.txt .;
    ) | zenity --progress --auto-close --title="Mise à jour des configurations utilisateur" --text="Mise à jour des configurations utilisateur" --percentage=0;
  else
    echo "Abandon des mises à jour";
  fi
  cd ~/.majConfUser;
  rm -R -f majConfUser;
fi
rm -R tmp;
