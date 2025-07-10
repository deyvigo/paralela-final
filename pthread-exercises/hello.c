#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

int thread_count;

void* Hello(void* rank) {
  long my_rank = (long)rank;
  printf("Hello from thread %ld\n", my_rank);
  return NULL;
}

int main(int argc, char* argv[]) {
  long thread;
  pthread_t* thread_handle;

  if (argc != 2) {
    fprintf(stderr, "Usage: %s <number of threads>\n", argv[0]);
    exit(EXIT_FAILURE);
  }

  thread_count = strtol(argv[1], NULL, 10);
  thread_handle = (pthread_t*)malloc(sizeof(pthread_t) * thread_count);

  // fork
  for (thread = 0; thread < thread_count; thread++) {
    pthread_create(&thread_handle[thread], NULL, Hello, (void*)thread);
  }

  // join
  for (thread = 0; thread < thread_count; thread++) {
    pthread_join(thread_handle[thread], NULL);
  }

  free(thread_handle);

  return 0;
}
