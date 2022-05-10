#!/bin/bash

#############fonction show usage
show_usage(){
echo usage :
echo "sauv_favori: [-h|--help] [-a] [-S] [-n] [-N] [-d] [-m] [-s] chemin.."
}
export -f show_usage


#############fonction help qui permet d’afficher le help à partir d’n fichier texte
HELP(){
	cat readme.txt
}
export -f HELP



#############supprimer sans arguments
remove(){
	cat -n favoris.txt
	read -p "please enter the number of the target you want to remove :" nbLine
	sed "${nbLine}d" favoris.txt >> temp.txt
	rm favoris.txt
	mv temp.txt favoris.txt
}
export -f remove


########"fonction version"
version(){
		#statements
		echo -e "\e[1;92m Authors: ISKANDER BAHROUN & AHMED AMRI \e[0m "
		echo -e "\e[1;92m version: 1.1 \e[0m "

}
export -f version



###########################fonction qui permet d'ajouter dans les favoris
Addfav(){
	read -p "enter the target you want to add favoris.txt :" target
	if [ -f "$target" ]
then
    ## le fichier existe ##
    aze=$(pwd)
    fullPath=$aze/$target;
    echo "$fullPath" >> favoris.txt
elif [[ -d "$target" ]]; then
    	echo "$target" >> favoris.txt
else
    echo "le fichier ou le repertoire n'existe pas"
fi
}
export -f Addfav



####################fonction qui se déplace dans un répertoire favori
Move(){
	cat favoris.txt
	read -p "please choose a directory :" target
	
	output=$(cat favoris.txt | grep -i $target )
	if [[ "$output" == "" ]]; then
		echo "directory not found";
	else
		cd $target
		exec bash
	fi
}
export -f Move



####fonction liste tous les favoris
Show(){

	cat favoris.txt
}
export -f Show

################# sauvegarder des images passé en argument et vérifier leurs nombres de pixels et les fixer à une valeur au
#choix si elles dépassent 700x700
Save(){
	for i in $*; do
		if [[ "$(identify -format '%f' $i)" == "$i" ]]; then
			size=$(convert $i -print "%wx%h\n" /dev/null) #get image size
			#echo "$i size : $size";

			x=$(convert $i -print "%w\n" /dev/null) #largeur de l'image
			y=$(convert $i -print "%h\n" /dev/null) #hauteur de l'image
			while [[ $x -ge 701 ]] || [[ $y -ge 701 ]]; do #tester si largeur ou hauteur > 700 
				echo " the image ($x x $y) is too large , please resize :"
				read -p "new width ($x) :" newX
				while [[ $newX -ge 701 ]]; do
					read -p "new width ($x) :" newX
				done

				read -p "new height ($y) :" newY
				while [[ $newY -ge 701 ]]; do
					read -p "new height ($y) :" newY
				done
				
				### now resize the image 
				convert $i -resize ${newX}x${newY} $i
				x=$newX
				y=$newY
			done
			echo $i >> favori_images
		else
			"$i is not an image"
		fi

	done
}
export -f Save
###### sauvegarder sans arguments
saveW(){

	read -p "enter the files you want to save (FORMAT:file1 file2 file3 ..." targets

	sauvegarder $targets
}
export -f saveW




###############renommer les images sauvegardés en adoptant ce format NOM_DATE_HEURE.jpg
Rename(){


	cat -n favori_images

	read -p "please enter the number of the image you want to rename :" nbLine

	file=$(sed -n ${nbLine}p favori_images)
	Date=$(date +%F)
	Time=$(date +%T)
	newName="${file}_${Date}_${Time}.jpg"
	convert $file $newName
	sed "/$file/d" favori_images >> tmp
	rm favori_images
	mv tmp favori_images
	rm $file
	echo $newName >> favori_images
	echo "++++++ $file renamed to $newName ++++++"
}
export -f Rename


#############affichage menu
Menu(){ 
	while [[ $choix -ne 10 ]] 
	do 
	echo "+++++++++++++++++++++++++MENU++++++++++++++++++++++++++++++++++++"
	echo "1- Pour afficher le help détaillé à partir d’un fichier texte" 
	echo "2- Interface graphque (YAD)" 
	echo "3- Afficher le nom des auteurs et version du code." 
	echo "4- sauvegarder des images" 
	echo "5- renommer image "
	echo "6- lister les images favoris." 
	echo "7- ajouter a favoris." 
	echo "8- supprimer un favoris." 
	echo "9- deplacer" 
	echo "10- QUIT" 
	read -p "donner un choix: " choix 
	case $choix in 
	1) HELP 
	;; 
	2) interface_graphique 
	;; 
	3) version  
	;; 
	4) save 
	;;
	5) renommer 
	;; 
	6) lister 
	;; 
	7) ajoutListeFavoris 
	;; 
	8) remove 
	;; 
	9) move 
	;; 
	10) exit 
	;;
 *) echo "veuillez choisir entre 1 et 10" 
 	esac 
 done
 } 
export -f Menu

#preparation d'interface graphique
cmdmain=(
   yad
   --center --width=400
   --image="gtk-dialog-info"
   --title="YAD interface graphique"
   --text="select an option."
   --button="Exit":1
   --form
      --field="Show usage":btn "bash -c show_usage "  
      --field="sauvegarder des images":btn "bash -c saveW "
      --field="renommer image":btn "bash -c rename "
      --field="lister les images favoris.":btn "bash -c lister"
      --field="ajouter a favoris.":btn "bash -c Addfav"
      --field="supprimer un favoris..":btn "bash -c remove"
      --field="deplacer.":btn "bash -c move"
      --field="author and version":btn "bash -c version"
      --field="HELP":btn "bash -c HELP"

)



########fonction ouvre fenetre yad
Graphic_interface(){
	while true; do
	    "${cmdmain[@]}"
	    exval=$?
	    case $exval in
	        1|252) break;;
	    esac
	done
}