#!/bin/bash

####################################################################
#                                                                  #
#  dat2LaTeX:       a cloven script by Simone Capodicasa           # 
#  homepage:        http://newton.ph.unito.it/~capodica            #
#  email:           capodica@studenti.ph.unito.it                  #
#  latest update:   2014/03/11                                     #
#                                                                  #
#  please mail me for every suggestion or question on this work    #
#                                                                  #
####################################################################

SCRIPT=(basename $0)

function Usage {
echo -e "
\033[1m\tdat2LaTeX:\ta cloven script by Simone Capodicasa\n
\thomepage:\tsimonecapodicasa.github.io\n
\temail:\t\tcapodica@studenti.ph.unito.it\n
\tlatest update:\t2014/03/11\n\n\033[0m
\033[1mUSAGE:\033[0m\n
\tdat2LaTeX.sh [-c \033[4mnumber\033[0m] [-v \033[4mstyle\033[0m] [-s \033[4mstyle\033[0m] [-a] [-t \033[4mtitle\033[0m] [-f \033[4m\"first line\"\033[0m] [-h] \033[4minput_file\033[0m \033[4moutput_file\033[0m\n\n
\033[1mDESCRIPTION:\033[0m\n
\t-h\n\t\t\tprints this help\n
\t-c \033[4mnumber\033[0m\n\t\t\tnumber of columns. This option is mandatory!\n
\t-a\n\t\t\tgenerate a standalone (compilable) .tex file\n
\t-s\n\t\t\tinsert an horizontal line between rows.\n
\t-v \033[4mstyle\033[0m\n\t\t\tvertical style (e.g. '{c|c|c}').\n
\t-t \033[4mtitle\033[0m\n\t\t\tthe caption of your table.\n
\t-f \033[4m\"first line\"\033[0m\n\t\t\tthe first line of your table, e.g. the description of your columns (space-separated, quotes are mandatory)\n"

exit 0
}

#stampo l'help se lo script è senza argomenti
if [ $# -eq 0 ] 
then
    echo
    Usage
    exit 1
fi
#setto i default
COLS=0
HSTYLE=0
VSTYLE=''
STANDALONE=0
TITLE=''
FLINE=""
#leggo le opzioni e setto le variabili opportune
while getopts ":c:sv:aht:f:" OPT
do
    case $OPT in
	c ) COLS=$OPTARG;;
	s ) HSTYLE=1;;
	v ) VSTYLE=$OPTARG;;
	a ) STANDALONE=1;;
	t ) TITLE=$OPTARG;;
	f ) FLINE=$OPTARG;;
	h ) Usage; exit 0;;
    esac
done
#setto lo stile verticale se l'utonto non lo ha fatto
COUNTER=0
if [ "$VSTYLE" = '' -a $COLS -ne 0 ]
then
    VSTYLE='{'
    while [ "$COUNTER" != "$COLS" ]
    do
	((COUNTER++))
	if [ "$COUNTER" != "$COLS" ]
	then
	    VSTYLE=$VSTYLE'c|'
	else
	    VSTYLE=$VSTYLE'c}'
	fi
    done
fi
#controllo se sono stati passati input ed output
shift $((OPTIND - 1))
if [ "$1" = "" ]
then
    echo -e 'Give me an input file!'
    read NEWFILE
else
    NEWFILE=$1
fi
INFILE=$NEWFILE
if [ "$2" = "" ]
then
    echo -e 'Give me an output file!'
    read NEWFILE
else
    NEWFILE=$2
fi
OUTFILE=$NEWFILE
#controllo come sono state passate le opzioni
while [ $COLS -eq 0 ]
do
    echo 'You did not set any number of columns. Set a number before continuing.'
    read COLS
done
while [ "$VSTYLE" = '' ]
do
    echo 'You did not set any vertical style. Set one style before continuing.'
    read VSTYLE
done
#controllo il file di input
ERR=1
while [ $ERR -eq 1 ]
do
    if [ -e $INFILE ]
    then
	ERR=0
    else
	echo $INFILE' does not exist. Insert an existing file name:'
	read NEWFILE
	if [ $NEWFILE = $INFILE ]
	then
	    echo
	    echo 'Look behind you, a Three-Headed Monkey!'
	    echo
	fi
	INFILE=$NEWFILE
    fi
done
#controllo il file di output
ERR=1
while [ $ERR -eq 1 ]
do
    if [ -e $OUTFILE ]
    then
	echo $OUTFILE' already exists. Overwrite it? (y/n)'
	read CHOICE
	if [ $CHOICE = y ]
	then
	    rm $OUTFILE
	    touch $OUTFILE
	    ERR=0
	else
	    echo 'Insert a new output file name:'
	    read NEWFILE
	    if [ $NEWFILE = $OUTFILE ]
	    then
		echo
		echo 'I am rubber, you are glue.'
		echo
	    fi
	    OUTFILE=$NEWFILE
	fi
    else
	touch $OUTFILE
	ERR=0
    fi
done
#leggo il file di input e scrivo il file di output
if [ $STANDALONE -eq 1 ]
then
    echo '\documentclass{article}' >> $OUTFILE
    echo '\begin{document}' >> $OUTFILE
fi
echo '\begin{table}[ht]' >> $OUTFILE
if [ "$TITLE" != "" ]
then
    echo "\caption{"$TITLE"}" >> $OUTFILE
fi
echo '\begin{center}' >> $OUTFILE
echo '\begin{tabular}'$VSTYLE >> $OUTFILE
if [ "$TITLE" != "" ]
then
    echo '\hline' >> $OUTFILE
    echo '\hline' >> $OUTFILE
fi
if [ "$FLINE" != "" ]
then
    IFS=' ' read -a ARRAY <<< "$FLINE"
    LINE=''
    for ((C=1; $C<=${#ARRAY[@]}; C++)); do
	if [ "$C" != "$COLS" ]
	then
	    LINE=$LINE${ARRAY[(($C - 1))]}' & '
	fi
	if [ "$C" == "$COLS" ]
	then
	    LINE=$LINE${ARRAY[(($C - 1))]}' \\ '
	fi
    done
    echo $LINE >> $OUTFILE
    echo '\hline' >> $OUTFILE
fi
if [ $HSTYLE -eq 1 ]
then
    echo '\hline' >> $OUTFILE
fi
TABLINE=''
COUNTER=1
for DATA in $(cut -d: -f1 $INFILE)
do
    if [ $COUNTER != $COLS ]
    then
	TABLINE=$TABLINE' '$DATA' &'
    fi
    if [ $COUNTER -eq $COLS ]
    then
	TABLINE=$TABLINE' '$DATA' \\'
	echo $TABLINE >> $OUTFILE
	if [ $HSTYLE -eq 1 ]
	then
	    echo '\hline' >> $OUTFILE
	fi
	COUNTER=0
	TABLINE=''
    fi
    ((COUNTER++))
done
echo '\end{tabular}' >> $OUTFILE
echo '\end{center}' >> $OUTFILE
echo '\end{table}' >> $OUTFILE
if [ $STANDALONE -eq 1 ]
then
    echo '\end{document}' >> $OUTFILE
    echo -e 'Now you can compile your tabular typing:\n\n\tpdflatex '$OUTFILE'\n\nEnjoy LaTeX!'
fi
if [ $STANDALONE -eq 0 ]
then
echo -e 'Output written on '$OUTFILE'.\nEnjoy LaTeX!'
fi
exit 0
