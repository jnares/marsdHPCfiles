#!/bin/bash

nf=$1

allSolsFile="allSolsFile.txt"
if [ ! -f $allSolsFile ]
then
    touch $allSolsFile
fi

allStatsFile="allStatsFile.txt"
if [ ! -f $allStatsFile ]
then
    touch $allStatsFile
fi

longNameFixFile="longNameFixFiles.txt"
touch $longNameFixFile
cntLong=($(wc -l $longNameFixFile))

allFixFile="allFix.txt"
if [ ! -f $allFixFile ]
then
    touch $allFixFile
fi

lengthFixFiles="lengthFixFiles.txt"
if [ ! -f $lengthFixFiles ]
then
    touch $lengthFixFiles
fi

# this is extra, to check
auxfile="auxFile.txt"
if [ -f $auxfile ]
then
    rm $auxfile
fi
touch $auxfile
auxlength="auxLength.txt"
if [ -f $auxlength ]
then
    rm $auxlength
fi
touch $auxfile

MAX_SUBMITTED_JOBS=5
#count=1
for i in *.fix
do
    echo "fixFile $i"
    sed '/^$/d' -i $i
    if [ -s $i ]
    then
	#echo "this file exists"
	name=`basename $i .fix`
	if [ ! -f stats_$name.txt ] # && (( count < MAX_SUBMITTED_JOBS ))
	then
	    len=${#name}
	    nameFixFile=$name.fix
	    if (( len > 50 )) 
	    then
		echo "$cntLong,$name" >> $longNameFixFile
		echo $cntLong
		mv $i $cntLong.fix
		nameFixFile=$cntLong.fix
		cntLong=$((cntLong+1))
	    fi
	    echo $nameFixFile
	    tmpfile="tmpfile"
	    tmplength="tmplength"
	    rm $tmpfile
	    rm $tmplength
	    echo "$nameFixFile" >> $tmpfile
	    wc -l $i
	    wc -c $i
	    cat $i >> $tmpfile
	    echo "" >> $tmpfile
  	    sed '/^$/d' -i $tmpfile
	    wc -l $tmpfile
	    wc -c $tmpfile
	    nlines=$(wc -l < $tmpfile)
	    #echo "nlines: $nlines"
	    echo "$nlines" >> $tmplength
	    cat $tmplength >> $lengthFixFiles
	    cat $tmpfile >> $allFixFile
	    cat $tmpfile >> $auxfile
	    rm $tmpfile
	    rm $i
	else
	    while IFS= read -r line
	    do
		if [[ ! $line == n* ]]
		then
		    echo "$name,$line" >> $allStatsFile
		fi
	    done < stats_$name.txt
	    rm stats_$name.txt
	    cat solutionRepresentatives_$name.txt >> $allSolsFile
	    rm solutionRepresentatives_$name.txt
	    rm $i
	    rm $name.out
	    rm $name.err
	fi
    fi
done

# retrieve the last MAX_SUBMITTED_JOBS .fix added to $allFixFile (DFS)
# and delete them from $allFixFile
fixFilesForHPC="fixFilesForHPC.txt"
if [  -f $fixFilesForHPC ]
then
    rm $fixFilesForHPC
fi
touch $fixFilesForHPC
totalNlines=$(tail -$MAX_SUBMITTED_JOBS $lengthFixFiles | paste -sd+ | bc)
#echo "totalNlines: $totalNlines"
tail -$totalNlines $allFixFile >> $fixFilesForHPC
#echo "we are here"
wc -c $allFixFile
#echo $fixFilesForHPC

# delete the used portions of $lengthFixFiles and $allFixFile
ncL=$(tail -$MAX_SUBMITTED_JOBS $lengthFixFiles | wc -c)
#echo "number of characters truncated from lenghFixFiles is $ncL"
truncate --size=-$ncL $lengthFixFiles
nc=$(wc -c < $fixFilesForHPC)
cp $allFixFile "tmpFixFile"
wc -c $fixFilesForHPC
#nc=$((nc+1))
#echo "number of characters truncated from allFixFile is $nc"
truncate --size=-$nc $allFixFile

python make-hpc-marsd.py $fixFilesForHPC $nf

nFixFiles=($(wc -l $lengthFixFiles))
return $nFixFiles
#condor_submit submit-solve-1.cmd

#while read p
#do
#    python make-condor-marsd.py $p $count $nf
#    count=$((count+1))
#done <allSubmit.txt

#return 1
