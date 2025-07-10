#include <stdio.h>
#include <omp.h>

int main(void) {
  int x = 17;

  #pragma omp parallel for private(x)
  for (int i = 0; i < 10; i++) {
    x += i;
    int id_t = omp_get_thread_num();
    printf("thread %d: x = %d\n", id_t, x);
  }

  printf("x = %d\n", x);
  return 0;
}