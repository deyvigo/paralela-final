#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#define N 12
int thread_count = 4;

int x[N] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12};
int y[N] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12};
int vector[N];

void* Prod(void* rank) {
  long my_rank = (long)rank;

  int local_n = N/thread_count;

  int my_first_row = my_rank * local_n;
  int my_last_row = (my_rank + 1) * local_n - 1;

  for (int i = my_first_row; i <= my_last_row; i++) {
    vector[i] = x[i] * y[i];
  }

  return NULL;
}

int main(int argc, char* argv[]) {
  long thread;
  pthread_t* thread_handle;

  thread_handle = (pthread_t*)malloc(sizeof(pthread_t) * thread_count);

  // fork
  for (thread = 0; thread < thread_count; thread++) {
    pthread_create(&thread_handle[thread], NULL, Prod, (void*)thread);
  }

  // join
  for (thread = 0; thread < thread_count; thread++) {
    pthread_join(thread_handle[thread], NULL);
  }

  for (int i = 0; i < 12; i++) {
    printf("%d\n", vector[i]);
  }

  free(thread_handle);

  return 0;
}
