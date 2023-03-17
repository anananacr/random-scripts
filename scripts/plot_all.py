import numpy as np
import matplotlib.pyplot as plt
import argparse
import pandas as pd
import seaborn as sns
import subprocess as sub
import glob
import os
from matplotlib.ticker import (MultipleLocator, FormatStrFormatter, AutoMinorLocator)

def main(raw_args=None):

    parser = argparse.ArgumentParser(
    description="Plot peak positions according to angle.")
    parser.add_argument("-i", "--input", type=str, action="store",
    help="hdf5 input image")
    parser.add_argument("-o", "--output", type=str, action="store",
    help="hdf5 output image")
    parser.add_argument("-s", "--start", type=int, action="store",
    help="hdf5 output image")
    parser.add_argument("-f", "--final", type=int, action="store",
    help="hdf5 output image")
    parser.add_argument("-e", "--exclude", type=int, action="append",
    help="hdf5 output image")
    args = parser.parse_args(raw_args)
    majorLocator = MultipleLocator(20)
    majorFormatter = FormatStrFormatter('%d')
    minorLocator = MultipleLocator(5)
    sns.set_context("paper")
	

    cmd=f"sed 's/.stream//g'<<<$(basename {args.input})"
    print(cmd)
    ## when testing partialator options
    #basename=str(sub.check_output(cmd, shell=True)[:-1])[2:-1]+'_'

    ## comparing multiple streams
    basename=str(sub.check_output(cmd, shell=True)[:-1])[2:-1]

    ## when testing process_hkl options
    #basename=str(sub.check_output(cmd, shell=True)[:-1])[2:-1]

    print(basename)
    files=list(glob.glob(f"./fom/{basename}*.dat"))
    #print(files)
    #y_label=['SNR']
    y_label=['SNR', 'CCstar', 'CC', 'CCstarTotal','Rsplit']
    index=np.arange(args.start,args.final+1,1)
    #print(index)
    #labels=['push 0.5','1.0','1.5']
    labels=[f'{basename}', f'{basename}']

    for idx,i in enumerate(y_label):
        fig = plt.figure(figsize=(10, 5), tight_layout=True)
        ax = fig.add_subplot(1,1,1)
        ax2 = ax.twiny()
        for idy,j in enumerate(index):
		
            #data_path = os.path.join(f'./fom/{basename}{j}_{y_label[idx]}.dat')
            data_path = os.path.join(f'./fom/{basename}_{y_label[idx]}.dat')
            print(f'./fom/{basename}_{y_label[idx]}.dat')
            if i=='SNR':
                data= pd.read_csv(data_path,delimiter=' ', usecols=(0,1,2,3,4,5,6,7,8,9,10), skipinitialspace=True)
                df=pd.DataFrame(data, columns=['Center','SNR','Meas'])
                d=df['SNR'].to_list()
                q=df['Center'].to_list()
                score=df['Meas'].to_list()
            else:
                data= pd.read_csv(data_path, delimiter=' ', usecols=(0,1,2,3), skipinitialspace=True)
                print(data)
                df=pd.DataFrame(data, columns=['1/d','centre', 'nref'])
                df=df.fillna(0)
                d=df['nref'].to_list()
                q=df['1/d'].to_list()
                score=df['centre'].to_list()
            ax.plot(q,score,marker='o', linestyle='-', label=labels[idy])
        ax.set_ylabel(y_label[idx], fontsize=12)
        ax.set_xlabel('1/d (1/nm)', fontsize=12)
        #ax.set_xlim(0.15,0.75)
        ax.yaxis.label.set_size(12)
        ax2.set_xlim(ax.get_xlim())
        ax2.set_xticks(q)
        ax2.set_xticklabels(d, rotation=45, ha='right')
        ax.tick_params(axis='both', which='major', labelsize=12)
        ax.tick_params(axis='both', which='minor', labelsize=12)
        ax2.set_xlabel("d (Å)",fontsize=12)
        ax2.tick_params(axis='both', which='major', labelsize=12)
        ax2.tick_params(axis='both', which='minor', labelsize=12)
        #print(tests)
        ax.legend(fontsize=12)
        #plt.ylim(0,100)
        #plt.xlim(0,2)
        plt.savefig(f'{basename}_{y_label[idx]}.pdf')
        plt.show()
        
        plt.close()


if __name__ == '__main__':
    main() 
