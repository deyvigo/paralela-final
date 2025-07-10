#include <stdio.h>
#include <omp.h>

int main() {
  int total = 0;

  #pragma omp parallel
  {
    #pragma omp master
    {
      printf("total de hilos: %d\n", omp_get_num_threads());
    }
    #pragma omp barrier
    printf("hilo %d || después de master\n", omp_get_thread_num());
    #pragma omp for
    for (int i = 0; i < omp_get_num_threads(); i++) {
      int id_t = omp_get_thread_num();
      #pragma omp atomic
      total += 2 * id_t;
    }
  }

  printf("suma total = %d\n", total);
}