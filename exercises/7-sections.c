#include <stdio.h>
#include <omp.h>

int main() {
  #pragma omp parallel
  {
    #pragma omp sections
    {
      printf("Hilo: %d || Sección 1\n", omp_get_thread_num());
      #pragma omp section
      {
        printf("Hilo: %d || Sección 2\n", omp_get_thread_num());
      }
      #pragma omp section
      {
        printf("Hilo: %d || Sección 3\n", omp_get_thread_num());
      }
    }
  }


  return 0;
}