/* example2.c */

#include <stdio.h>

#include "emd.h"


float _COST[5][3] = {
  3, 5, 2,
  0, 2, 5,
  1, 1, 3,
  8, 4, 3,
  7, 6, 5
};

float dist(feature_t *F1, feature_t *F2) { return _COST[*F1][*F2]; }

main()
{
  feature_t   f1[5] = { 0, 1, 2, 3, 4 },
	      f2[3] = { 0, 1, 2 };
  float       w1[5] = { 0.4, 0.2, 0.2, 0.1, 0.1 },
              w2[3] = { 0.6, 0.2, 0.1 };
  signature_t s1 = { 5, f1, w1},
	      s2 = { 3, f2, w2};
  float       e;
  flow_t      flow[7];
  int         i, flowSize;

  e = emd(&s1, &s2, dist, flow, &flowSize);

  printf("emd=%f\n", e);
  printf("\nflow:\n");
  printf("from\tto\tamount\n");
  for (i=0; i < 7; i++)
    if (flow[i].amount > 0)
      printf("%d\t%d\t%f\n", flow[i].from, flow[i].to, flow[i].amount);
}
