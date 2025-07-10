#include <stdio.h>
#include <omp.h>

int main() {
  int i = 0;

  #pragma omp parallel
  {
    #pragma omp for schedule(static) // nowait para eliminar la barrera implícita
    for (i = 0; i < 100000; i++) {
      printf("thread %d: i = %d\n", omp_get_thread_num(), i);
    }
    printf("thread %d || salió del parallel for\n", omp_get_thread_num());
  }

  return 0;
}