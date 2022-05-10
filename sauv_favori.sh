#!/bin/bash
source source.sh


#debut script

#tester la présence d’au moins un argument, sinon il affiche l’usage sur la
#sortie d’erreur et échoue.
if [[ $# -eq "0" ]]; then
	show_usage
	exit
fi


#lire les options (-m|-a|.....)
while getopts "arhvlsAnmcg" option
do
echo "getopts a trouvé l'option $option"
case $option in
	h)
		HELP
	;;

	g)
		Graphic_interface
	;;

	a)
		Addfav 
	;;

	r)
		remove 
	;;

	v)
		version
	;;

	l)
		Show
	;;

	s)
		
		Save $2
	;;

	n)
		Rename
	;;

	c)
		Move 
	;;
	m) 
	Menu		
	;;


esac
done
exit 0