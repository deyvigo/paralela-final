#include <stdio.h>
#include <omp.h>

void calcular_suma(int *, int);

int main(void) {
  int total = 0;

  #pragma omp parallel for
  for (int i = 0; i < 10; i++) {
    int id_t = omp_get_thread_num();
    int total_threads = omp_get_num_threads();
    printf("Thread %d: T_threads = %d total = %d <=> increment %d\n", id_t, total_threads, total, i);
    #pragma omp atomic
    total += i;
  }

  printf("Total: %d\n", total);
  return 0;
}

void calcular_suma(int *total, int increment) {
  *total += increment;
}