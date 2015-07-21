/* example1.c */

#include <stdio.h>
#include <math.h>

#include "emd.h"

float dist(feature_t *F1, feature_t *F2)
{
  int dX = F1->X - F2->X, dY = F1->Y - F2->Y, dZ = F1->Z - F2->Z;
  return sqrt(dX*dX + dY*dY + dZ*dZ); 
}

main()
{
  feature_t   f1[4] = { {100,40,22}, {211,20,2}, {32,190,150}, {2,100,100} },
	      f2[3] = { {0,0,0}, {50,100,80}, {255,255,255} };
  float       w1[5] = { 0.4, 0.3, 0.2, 0.1 },
              w2[3] = { 0.5, 0.3, 0.2 };
  signature_t s1 = { 4, f1, w1},
	      s2 = { 3, f2, w2};
  float       e;

  e = emd(&s1, &s2, dist, 0, 0);

  printf("emd=%f\n", e);
}
