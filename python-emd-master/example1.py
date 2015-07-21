from collections import namedtuple
from emd import emd
from math import sqrt

Feature = namedtuple("Feature", ["x", "y", "z"])


def distance(f1, f2):
    return sqrt( (f1.x - f2.x)**2  + (f1.y - f2.y)**2 + (f1.z - f2.z)**2 )


def main():
    features1 = [Feature(100, 40, 22), Feature(211, 20, 2),
                 Feature(32, 190, 150), Feature(2, 100, 100)]
    weights1  = [0.4, 0.3, 0.2, 0.1]
    
    features2 = [Feature(0, 0, 0), Feature(50, 100, 80), Feature(255, 255, 255)]
    weights2  = [0.5, 0.3, 0.2]
    
    print emd( (features1, weights1), (features2, weights2), distance )


if __name__ == "__main__":
    main()