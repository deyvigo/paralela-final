#include <stdio.h>
#include <omp.h>

int main() {
  int i = -1;

  #pragma omp parallel for
  for (i = 0; i < 10; i++) {
    int id_t = omp_get_thread_num();
    printf("thread %d: i = %d\n", id_t, i);
  }

  printf("i = %d\n", i);

  return 0;
}