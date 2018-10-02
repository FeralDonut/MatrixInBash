#!/bin/bash

tempCol="tempcolfile"
tempRow="temprowfile"
tempMean="tempmeanfile"
tempSum="tempsumfile"

#function for dims
dims()
{
  rowNum=0

  #parse through the file and count how many rows there are 
  while read myLine
  do
    rowNum=`expr $rowNum + 1`
  done < $matrixFile

  #count the number of columns by counting elements in the first line of the matrixFile
  colNum=$( head -n 1 $matrixFile | wc -w)  
  echo -e "$rowNum $colNum"
}

#function for transpose
transpose()
{
  lineNum=0
  i=1

numcol=$( head -n 1 $matrixFile | wc -w)

#Reversing into temp files and getting rid of trailing tab
while [[ "$i" -le "$numcol" ]]
  do
     cut -f $i $matrixFile > $tempCol
     cat $tempCol | tr -s '\n' '\t' > "$tempRow"
     rev "$tempRow" >"temp222"
     cat "temp222" | cut -c 2-  >"temp333"
     rev "temp333">$tempRow
     cat $tempRow
     i=`expr $i + 1`
  done
}

mean()
{
  i=1
  numcol=$( head -n 1 $matrixFile | wc -w)	#Get number of columns 

  while [[ $i -le $numcol ]]
  do
     
  count=0
  sum=0
  cut -f $i $matrixFile > $tempCol

  while read num
  do
     sum=`expr $sum + $num`
     count=`expr $count + 1`
  done <$tempCol

#Equation given to us in program description
mean=$(((sum + (count/2)*( (sum>0)*2-1 )) / count))


echo "$mean" > "$tempMean"
cat $tempMean | tr "\n" "\t" > "$tempRow"

#remove trailing tabs
if [[ $i -eq $numcol ]]
then
rev "$tempRow" >"temp222"
cat "temp222" | cut -c 2- >"temp333"
rev "temp333">$tempRow
fi

cat $tempRow

i=$((i+1))

done

rm -f tempmeanfile

}

add()
{
   #Reading matrices into temp files 
   while read line1 <&3 && read line2 <&4
   do
      echo "$line1" | tr "\n" "\t" >> "temp50"
      echo "$line2" | tr "\n" "\t" >> "temp60"
   done 3<$matrixFile 4<$fileTwo
   echo >>"temp50"
   echo >>"temp60"

cat "temp60" >> "temp50"

i=1
x=1

while [ $i -le $totalNum ]
do
   sum=0
   cut -f $i "temp50" > "temp55"

   while read num
   do
      sum=$(($sum + $num))
   done <"temp55"

   echo "$sum" | tr "\n" "\t" >> "temp65"
   
   #try and remove hanging tab
   if [[ "$x" -eq "$numcolOne" ]]
   then
      rev "temp65" > "temp222"
      cat "temp222" | cut -c 1- >"temp333"
      rev "temp333">"temp65"
      x=0
   fi

   i=$((i+1))
   x=$((x+1))

done

cat "temp65"

#remove temp files
rm -f temp50   
rm -f temp55
rm -f temp60
rm -f temp65
rm -f temp70
rm -f temp75
rm -f temp222
rm -f temp333

}

mulitply()
{
  echo "Multiply Function"
}

  #count the number of arguments passed in
  argNum=$#


  #Since dims and mean both only need one matrix will check to see if dims or mean was passed
  #as the first argument before checking the number of matrices passed
  if [ $1 = "dims" ] || [ $1 = "mean" ]
    then

      #print to stderr if too many arguments are passed in
      if (("$argNum" > 2 ))
      then
          echo "Too many arguments for $1" 1>&2
          exit 1
        fi

      #print to stderr if the file is not readable
      #source on how to tell a file is readable
      #https://askubuntu.com/questions/558977/checking-for-a-file-and-whether-it-is-readable-and-writable
      if [ $2 != -r ]
      then
       echo "$2 is not a readable file" 1>&2
       exit 1
      fi

      
      if [ $# -gt 1 ]
      then
         matrixFile=$2
       fi


   

      if [ $1 = "dims" ]
      then
        dims $matrixFile
      fi

      if [ $1 = "mean" ]
      then
	 mean $matrixFile
      fi



    fi

#Executing transpose
    if [ $1 = "transpose" ]
    then


      if (( "$#" > 2 ))
      then
          echo "Invalid number of arguments" 1>&2
          exit 1

        elif [ $# -gt 1 ]
        then
           matrixFile=$2
           fileTwo=$3


        elif [ $# -eq 1 ]
        then
           matrixFile=tmp
           cat > $matrixFile
           #echo "Cat has finished"
        fi


      if [ ! -r $2 ]
        then
          echo "Invalid file" 1>&2        #Redirects stdout to stderr 1>&2
          exit 1
      fi

      transpose $matrixFile

    fi


#Executing add
    if [ $1 = "add" ]
    then

      if [ $# -ne 3 ]
      then
        echo "Invalid number of arguments" 1>&2
        exit 1
      fi

      if [ ! -r $2 ] || [ ! -r $3 ]
      then
        echo "Invalid file" 1>&2
        exit 1
      fi

      if [ $# -eq 3 ]
      then
	 matrixFile=$2
	 fileTwo=$3
      fi

rowNumOne=0
rowNumTwo=0                                                        
numcolOne=$( head -n 1 $matrixFile | wc -w)  
numcolTwo=$( head -n 1 $fileTwo | wc -w)                              
totalNum=0

while read myLine
do
   rowNumOne=`expr $rowNumOne + 1`
done <$matrixFile
                                                                  
while read myLine
do
   rowNumTwo=`expr $rowNumTwo + 1`
done <$fileTwo
          
totalNum=$((rowNumOne * numcolOne))

if [ $numcolOne -ne $numcolTwo ] || [ $rowNumOne -ne $rowNumTwo ]
then
   echo "You must have the same dimensions" 1>&2
   exit 1
fi

add $matrixFile $fileTwo


fi