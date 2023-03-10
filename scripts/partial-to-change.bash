#!/bin/bash

INPUT=$1
stream=$(sed 's/.stream//g'<<<$(basename $INPUT))
#09 data=${stream}_part09_maxadu_push1
data=${stream}
pg="mmm" #"2" #

pdb=/asap3/petra3/gpfs/p09/2022/data/11013671/scratch_cc/rodria/pdb/lysozyme.cell
#pdb=/asap3/petra3/gpfs/p09/2022/data/11013671/scratch_cc/galchenm/pdb/FosAKP_01_grid_fly_002_100humidity.cell #FosAKP_01_lowhum1_grid_fly_002_reduced_humidity.cell #FosAKP_lowhum2_01_grid_fly_002.cell #fosakp_ortho_p.cell #


HIGHRES=1.5
LOWRES=20
resext=0.0 # total CC* is calculated to highres+resext
highres="--highres=${HIGHRES}"      #<- number gives res limit
lowres="--lowres=${LOWRES}" 
nsh=20 # number of shells
#maxB="--max-rel-B=50"
model=xsphere
#model=unity
iterations=3 #2,3
push="--push-res=1.0" #"--push-res=0.2" "--push-res=0.5" "--push-res=1.5"
minres="--min-res=5"

partialator="partialator"

ERRORDIR=error

source /etc/profile.d/modules.sh
module load xray
#module load hdf5/1.10.5
module load anaconda3/5.2
module load maxwell
module load crystfel
    # Job name
    NAME=$data

    SLURMFILE="${NAME}.sh"

    echo "#!/bin/sh" > $SLURMFILE
    echo >> $SLURMFILE

    echo "#SBATCH --partition=cfel,all" >> $SLURMFILE  # Set your partition here
#    echo "#SBATCH --partition=upex" >> $SLURMFILE  # Set your partition here

    echo "#SBATCH --time=2:00:00" >> $SLURMFILE
#    echo "#SBATCH --exclude=max-exfl109,max-exfl103" >> $SLURMFILE
    echo "#SBATCH --nodes=1" >> $SLURMFILE
    echo "#SBATCH --nice=100" >> $SLURMFILE
    echo "#SBATCH --mem=500000" >> $SLURMFILE
    #echo "#SBATCH --cpu-freq=2600000" >> $SLURMFILE  # TO TEST !!!
    #echo "#SBATCH --cores-per-socket=32" >> $SLURMFILE
    echo >> $SLURMFILE

#    echo "#SBATCH --workdir   $PWD" >> $SLURMFILE
    echo "#SBATCH --job-name  $NAME" >> $SLURMFILE
    echo "#SBATCH --output    $ERRORDIR/$NAME-%N-%j.out" >> $SLURMFILE
    echo "#SBATCH --error     $ERRORDIR/$NAME-%N-%j.err" >> $SLURMFILE
    echo >> $SLURMFILE

    echo "source /etc/profile.d/modules.sh" >> $SLURMFILE
    echo "module load xray" >> $SLURMFILE
    echo "module load hdf5-openmpi/1.10.5" >> $SLURMFILE
    echo "module load maxwell crystfel" >> $SLURMFILE
	echo "module load hdf5/1.10.5" >> $SLURMFILE
    echo "indexamajig --version" >> $SLURMFILE

    echo >> $SLURMFILE

    #command="$partialator --no-logs --max-adu=7500 --iterations=$iterations --model=$model "$maxB" "$minres" "$push" -i $stream.stream -o $data.hkl -y $pg -j 80"
    #command="$partialator --no-logs --max-adu=7500 --iterations=$iterations --model=$model "$maxB" "$minres" "$push" -i $stream.stream -o $data.hkl -y $pg -j 80"
    command="$partialator --no-logs --iterations=$iterations --model=$model "$minres" "$push" --max-adu=20000 -i $stream.stream -o $data.hkl -y $pg -j 20"
    echo $command >> $SLURMFILE
        #total CC* calculation
    highres1="--highres="`echo $HIGHRES + $resext | bc`
#    echo $highres1
    command="compare_hkl -p $pdb -y $pg $highres1 $lowres --nshells=1 --fom=CCstar --shell-file=${data}_CCstarTotal.dat $data.hkl1 $data.hkl2"
    echo $command >> $SLURMFILE

    command="compare_hkl -p $pdb -y $pg $highres $lowres  --nshells=$nsh --fom=CCstar --shell-file=${data}_CCstar.dat $data.hkl1 $data.hkl2"
    echo $command >> $SLURMFILE

    command="compare_hkl -p $pdb -y $pg "$highres" $lowres --nshells=$nsh --fom=Rsplit --shell-file=${data}_Rsplit.dat $data.hkl1 $data.hkl2"
    echo $command >> $SLURMFILE

    command="compare_hkl -p $pdb -y $pg "$highres" $lowres --nshells=$nsh --fom=CC --shell-file=${data}_CC.dat $data.hkl1 $data.hkl2"
    echo $command >> $SLURMFILE

    command="compare_hkl -p $pdb -y $pg "$highres" $lowres --nshells=$nsh --fom=CCano --shell-file=${data}_CCano.dat $data.hkl1 $data.hkl2"
    echo $command >> $SLURMFILE

    command="check_hkl -p $pdb -y $pg "$highres" $lowres --nshells=$nsh --shell-file=${data}_SNR.dat $data.hkl"
    echo $command >> $SLURMFILE

    command="check_hkl -p $pdb -y $pg "$highres" $lowres --nshells=$nsh --wilson --shell-file=${data}_Wilson.dat $data.hkl"
    echo $command >> $SLURMFILE

    sbatch $SLURMFILE
	

