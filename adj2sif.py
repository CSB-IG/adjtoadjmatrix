
# Convierte una matriz de adyacencia de ARACNe en un archivo
# de interacciones SIF con la matriz triangular
import sys

if __name__ == '__main__':
    fname = sys.argv[1]
    lines = [line.rstrip('\n') for line in open(fname)]

    names = lines[0].split()

    for i in range(0, len(lines)-1):
      vals = lines[i+1].split()
      for j in range(1, len(vals)):
        print(names[i] + "\t" + vals[j] + "\t" + names[i+j])
