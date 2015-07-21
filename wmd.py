#start
import pdb, sys, numpy as np, pickle, multiprocessing as mp
sys.path.append('python-emd-master')
from emd import emd

load_file = sys.argv[1]
save_file = sys.argv[2]

with open(load_file) as f:
    [X, BOW_X, y, C, words] = pickle.load(f)
n = np.shape(X)
n = n[0]
D = np.zeros((n,n))
for i in xrange(n):
    bow_i = BOW_X[i]
    bow_i = bow_i / np.sum(bow_i)
    bow_i = bow_i.tolist()
    BOW_X[i] = bow_i
    X_i = X[i].T
    X_i = X_i.tolist()
    X[i] = X_i

def distance(x1,x2):
    return np.sqrt( np.sum((np.array(x1) - np.array(x2))**2) )

def get_wmd(ix):
    n = np.shape(X)
    n = n[0]
    Di = np.zeros((1,n))
    i = ix
    print '%d out of %d' % (i, n)
    for j in xrange(i):
        Di[0,j] = emd( (X[i], BOW_X[i]), (X[j], BOW_X[j]), distance)
    return Di 
            

def main():
    n = np.shape(X)
    n = n[0]
    pool = mp.Pool(processes=8)

    pool_outputs = pool.map(get_wmd, list(range(n)))
    pool.close()
    pool.join()

    WMD_D = np.zeros((n,n))
    for i in xrange(n):
        WMD_D[:,i] = pool_outputs[i]

    with open(save_file, 'w') as f:
        pickle.dump(WMD_D, f)

if __name__ == "__main__":
    main()




