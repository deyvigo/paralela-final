#include <stdio.h>
#include <omp.h>

int calc(int, int);

int main() {
  int total, res = 0;
  #pragma omp parallel
  {
    #pragma omp single
    {
      printf("total de hilos: %d\n", omp_get_num_threads());
    }
    #pragma omp for
    for (int i = 0; i < omp_get_num_threads(); i++) {
      int id_t = omp_get_thread_num();
      #pragma omp critical
      {
        res = calc(id_t, i);
        res *= 2;
        total += res;
      }
    }
  }

  printf("suma total = %d\n", total);

  return 0;
}

int calc(int id_t, int i) {
  return id_t + i;
}