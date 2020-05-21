#!/bin/bash

INPUT_SEED="al_sno_seed.gin"
SUM_SQ_STRING="Final sum of squares ="
SUM_SQ_RES=""
#grep "Final sum of squares =" fit21.out  | awk '{print $6}'

#LIST OF TAR VARIABLES
# TAR_CHARGE_CORE / TAR_CHARGE_SHELL / TAR_SPRING / TAR_BUCK_A / TAR_BUCK_RHO

MPI_PREFIX="mpirun -np 1 "	#
PRO_PREFIX="gulp-mpi"		#
INPUT_TAR=""			# IN  NAME TAR
OUT_TAR=""			# OUT NAME TAR

# USER CUSTOM SECTION

S_CHARGE_SUM="2"
S_CHARGE_STA="-5.4"
S_CHARGE_END="-3.8"
S_CHARGE_DEL="0.1"			# CHARGE SET
CHARGE_CYCLE=$( echo "( $S_CHARGE_STA - ( $S_CHARGE_END ))/( $S_CHARGE_DEL )*-1" | bc )

SPRING_STA="40.0"
SPRING_END="240.0"
SPRING_DEL="40.0"			# SPRING SET
SPRING_CYCLE=$( echo "( $SPRING_END - ( $SPRING_STA ))/( $SPRING_DEL )" | bc )

BUCK_A_STA="40000.0"
BUCK_A_END="80000.0"
BUCK_A_DEL="5000.0"			# BUCK A SET
BUCK_A_CYCLE=$( echo "( $BUCK_A_END - ( $BUCK_A_STA ))/ ( $BUCK_A_DEL)" | bc )

BUCK_RHO_STA="0.19"
BUCK_RHO_END="0.23"
BUCK_RHO_DEL="0.005"			# BUCK RHO SET
BUCK_RHO_CYCLE=$( echo "( $BUCK_RHO_END - ( $BUCK_RHO_STA ))/ ( $BUCK_RHO_DEL )" | bc )

#echo "$CHARGE_CYCLE*$SPRING_CYCLE*$BUCK_A_CYCLE*$BUCK_RHO_CYCLE*10/3600/24" | bc -l
#echo "$CHARGE_CYCLE*$SPRING_CYCLE*$BUCK_A_CYCLE*$BUCK_RHO_CYCLE"


# i BUCK A
# j CARGE
# k SPRING
# l BUCK RHO

if [ -f result.txt ]; then
    rm result.txt
fi

if [ -f temp.gin ]; then
    rm temp.gin
fi

touch result.txt

for (( i=0; i<$BUCK_A_CYCLE; i++ )); do
	for (( j=0; j<$CHARGE_CYCLE; j++)); do
		for (( k=0; k<$SPRING_CYCLE; k++ )); do
			for (( l=0; l<$BUCK_RHO_CYCLE; l++ )); do

				# SET PARAMETERS
				S_CHARGE_CUR=$( echo "( $S_CHARGE_STA ) + $j * ( $S_CHARGE_DEL )" | bc -l )
				C_CHARGE_CUR=$( echo "( $S_CHARGE_SUM ) - ( $S_CHARGE_CUR )" | bc -l )
				BUCK_A_CUR=$( echo "( $BUCK_A_STA ) + $i * ( $BUCK_A_DEL )" | bc -l)
				BUCK_RHO_CUR=$( echo "( $BUCK_RHO_STA ) + $l * ( $BUCK_RHO_DEL )" | bc -l)
				SPRING_CUR=$( echo "( $SPRING_STA ) + $k * ( $SPRING_DEL )" | bc -l)

				cp $INPUT_SEED temp.gin
				sed -i "s/TAR_CHARGE_CORE/"$C_CHARGE_CUR"/g" temp.gin
				sed -i "s/TAR_CHARGE_SHELL/"$S_CHARGE_CUR"/g" temp.gin

				sed -i "s/TAR_SPRING/"$SPRING_CUR"/g" temp.gin
				sed -i "s/TAR_BUCK_A/"$BUCK_A_CUR"/g" temp.gin
				sed -i "s/TAR_BUCK_RHO/"$BUCK_RHO_CUR"/g" temp.gin

				SUM_SQ_RES=""

				$PRO_PREFIX < temp.gin > "$i"_"$j"_"$k"_"$l".out

				if [ -f "$i"_"$j"_"$k"_"$l".out ]; then

					SUM_SQ_RES=$( grep "$SUM_SQ_STRING" "$i"_"$j"_"$k"_"$l".out | awk '{print $6}' )

				    	if [ -z $SUM_SQ_RES ]; then
						rm "$i"_"$j"_"$k"_"$l".out
				    	else
						echo "$i"_"$j"_"$k"_"$l"     $SUM_SQ_RES >> result.txt
				    	fi
				fi

				rm temp.gin

				#echo $S_CHARGE_CUR $C_CHARGE_CUR $BUCK_A_CUR $BUCK_RHO_CUR $SPRING_CUR
			done
		done
	done
done


