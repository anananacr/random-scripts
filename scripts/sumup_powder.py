import h5py
import hdf5plugin
import numpy as np
import argparse

def main():
    parser=argparse.ArgumentParser(
        description="Merge summed up Jungfrau images.")
    parser.add_argument("-i", "--input", type=str, action="store",
        help="path to H5 data files")
    parser.add_argument("-n", "--n_frames", default=None, type=int, action="store",
        help="number of frames to sum")
    parser.add_argument("-o", "--output", type=str, action="store",
        help="path to H5 data files")
    args = parser.parse_args()

    files=open(args.input,'r')
    paths=files.readlines()

    count=0
    for i in paths:
        hdf5_file=str(i[:-1])
        f=h5py.File(hdf5_file,'r')
        print(f.keys())
        if args.n_frames is None:
            data=np.array(f['entry/data/data'])
        else:
            data=np.array(f['entry/data/data'])[:args.n_frames]
        if count==0:
           acc=np.zeros((data[0].shape))

        for j in data:
            acc+=j

    g=h5py.File(args.output,'w')
    g.create_dataset('data', data=acc)
    g.close()

if __name__ == '__main__':
    main()
