#import "@local/commons-tenplate:1.0.0": inf_make_cover, common_content_body

#common_content_body()[
  #inf_make_cover(
    alumns: ("Gomez Olivas, Deyvi Pedro",),
    inform_name: "Proyecto de Programación Paralela",
    teacher_name: "Paucar Curasma, Herminio",
  )

  *1. Identifique los siguientes bucles*
  - Versión secuencial
  ```c
  double res[10000];

  for (i = 0; i < 10000; i++)
    calculo_pesado(&res[i]);
  ```
  - Versión paralela
  ```c
  double res[10000];

  #pragma omp parallel for
  for (i = 0; i < 10000; i++)
    calculo_pesado(&res[i]);
  ```

  (a) Explique brevemente la diferencia de ejecución existente entre estos dos ejemplos de bucles.

  En el caso de la versión secuencial, el for recorrerá todo el vector de manera ordenada hasta el final.
  Mientras que en la versión paralela, similar a lo realizado en clase con MPI, cuando se usaban límites para delimitar lo que debía recorrer proceso, la directiva ```#pragma omp parallel for``` realizará el recorrido con el mismo comportamiento.

  (b) Si un usuario está usando un procesador de cuatro núcleos, ¿qué se puede afirmar respecto al rendimiento con la adición de una sola línea de código ```#pragma omp parallel for``` en la versión paralela?

  Se crearán 4 hilos, y cada uno de ellos operará con una parte del vector de manera paralela. El vector tendría segmentos. Como es de 10000 elementos:
  - 10000/4 = 2500 elementos por hilo
  - \[0, 2500\[
  - \[2500, 5000\[
  - \[5000, 7500\[
  - \[7500, 10000\[

  *2. shared vs private*

  Explique la diferencia entre las cláusulas (atributos) shared y private con respecto al compartimiento de datos entre hilos, cuando se usan en una directiva ```c #pragma omp parallel for```.

  - private:
  Se crea una copia de la variable indicada por cada hilo, pero no se inicializan.
  - firstprivate:
  Similar a private, pero en cada iteración del hilo se inicializa la variable con el valor proporcionado en firstprivate.
  - lastprivate:
  Pasa el valor de la variable en la última interación a la variable global.
  - shared:
  Todos los hilos comparten la variable. El valor inicial se mantiene y el valor final puede ser modificado por cualquier hilo.
  Esta variable puede dar una condición de carrera.

  *3. Explique cómo funcionan la funciones*

  (a) ¿Cómo funcionan ```c omp_set_num_threads()``` y ```c omp_get_thread_num()``` en una región paralela ```c omp parallel```?

  - omp_set_num_threads: Establece el número de hilos a usar en la región paralela.
  - omp_get_thread_num: Devuelve el número de hilo actual.
  \* No confundir con omp_get_num_threads que devuelve el número de hilos total.

  (b) Si no se usa ```c omp_set_num_threads()```, ¿cómo especificar el número de hilos en Linux?

  - Como prefijo en la ejecución del programa 
  ```bash
  OMP_NUM_THREADS=n ./programa
  ```
  - Estableciendo la variable de entorno OMP_NUM_THREADS
  ```bash
  export OMP_NUM_THREADS=n
  // luego ejecutar el programa
  ./programa
  ```

  \* Cuando no se usa ninguno de los métodos mencionados, el número de hilos se establecerá automáticamente en el número de núcleos del sistema. Se puede consultar con el comando:
  ```bash
  nproc
  ```

  *4. Región paralela verdadero/falso*

  ```c
  OMP PARALLEL double A[10000];
  omp_set_num_threads(4);
  #pragma omp parallel
  {
    int th_id = omp_get_thread_num();
    calculo_pesado(th_id, A);
  }
  printf("Terminado");
  ```

  (a) ¿Se señala el inicio de la ejecución de los hilos?

  La directiva ```c #pragma omp parallel``` indica la región paralela. Es donde se hará el fork de los hilos.
  
  (b) ¿Los hilos son sincronizados?
  
  No, los hilos no se sincronizan. Cuando se hace el fork de los hilos, cada hilo hace sus tareas independientemente de los demás. Se podría precisar que sí terminan sincronizados cuando se hace el join, pero durante la ejecución del código no hay directivas que garantizen que los hilos se sincronicen.
  
  (c) ¿El vector A es compartido?
  
  Sí, si no se especifica nada, por defecto A sería shared.

  (d) ¿Se usaron funciones de OpenMP además de directivas?

  Sí, ```c omp_set_num_threads()``` y ```c omp_get_thread_num()``` son funciones de OpenMP.

  *5. Sobre el código siguiente se afirma verdadero/falso*
  ```c
  #define N 10000;
  int i;
  #pragma omp parallel
    #pragma omp for
    for (i = 0; i < 10000; i++) {
      calculo();
    }
    printf("Terminado");
  ```

  (a) ¿Las iteraciones son distribuidas entre los hilos?
  
  Sí, la directiva ```c #pragma omp for``` distribuye las iteraciones entre los hilos creados por la directiva ```c #pragma omp parallel```.

  (b) ¿Existe una barrera implícita de sincronización entre hilos al final del bucle?

  Sí, cuando termina la directiva ```c #pragma omp for``` se espera que todos los hilos terminen para continuar con la ejecución del código dentro de la región paralela, si existiera.
  
  (c) ¿omp for puede complementarse con schedule para especificar cómo hacer la distribución de carga del ```c for (i=0 ; i < 10000 ; i++)```?

  Sí, se puede usasr el atributo ```c schedule(static)``` para que el código dentro de la directiva ```c #pragma omp for``` se distribuya de manera específica. Existen otras opciones, como: 
  - static:
  - dynamic: 
  - guided:
  - runtime:

  *6. Claúsula reduction*
  ```c
  #include <omp.h>
  #define NUM_THREADS 4
  ...
  int i, tmp, res = 0;
  #pragma omp parallel for reduction(+:res) private(tmp)
  {
    for (i = 0; i < 15; i++) {
      tmp = Calculo();
      res += tmp;
    }
    printf("O resultado vale %d", res);
  }
  ```

  (a) ¿La variable res debe ser shared o private? Explique.

  res debe ser private, porque se está haciendo una operación de acumulación en este caso reducción.
  La directiva ```c reduction(+:res)``` ya trata a la variable res como private. La inicializa con un valor neutro de la operación a reducir y hace una acumulación local. Al final estas sumas locales son reducidas en la variable global res.
  
  (b) Vea el código arriba y explique qué sucede con respecto a la variable res, indicada en reduction(+:res). Dé un ejemplo de cómo lo entiende, para 4 hilos e i variando de 0 a 15.
  
  La variable res es la que acumulará el valor de las operaciones, en este caso una suma con tmp, es la acumulación de tmp sobre res.
  - Hilo 0: [0, 1, 2, 3]
    - i == 0: Se calcula tmp y se suma a res.
    - i == 1: Se calcula tmp y se suma a res.
    - i == 2: Se calcula tmp y se suma a res.
    - i == 3: Se calcula tmp y se suma a res.
    Al final res termina sumando 4 veces tmp.
  - Hilo 1: [4, 5, 6, 7]
  - Hilo 2: [8, 9, 10, 11]
  - Hilo 3: [12, 13, 14, 15]
  Lo mismo para los otros hilos.

  Entonces:
  $ "res" = 4*"tmp" + 4*"tmp" + 4*"tmp" + 4*"tmp" = 16*"tmp" $


  *7. Distribución de trabajo con secciones paralelas. Se puede usar omp sections, cuando no se usen loops.*
  ```c
  #pragma omp parallel
  {
    #pragma omp sections
    {
      Calculo();
      #pragma omp section
        Calcul2();
      #pragma omp section
        Calcul3();
    }
  }
  ```

  (a) ¿Se distribuyen las secciones entre los hilos o los hilos entre las secciones?

  Se distribuyen las secciones entre los hilos. Cada sección se pasa a un hilo distinto.
  
  (b) Explique cómo funciona la región paralela y las secciones paralelas definidas.

  - La región paralela ```c #pragma omp parallel``` hará un fork de los hilos.
  - Luego las secciones de distribuirán entre los hilos. Es decir cada hilo ejecutará una sección.
  - Hay 3 secciones
    - Sección 1: Calculo() sección implicíta luego de ```c #pragma omp sections```
    - Sección 2: Calcul2()
    - Sección 3: Calcul3()
  #image("images/img_1751988564964.png")

  *8. Sincronización*
  Existen algunas instrucciones para sincronizar los accesos a la memoria compartida. Proponga un ejemplo de cada caso (a), (b), y (c).

  (a) Sección crítica

  ```c #pragma omp critical { ... }```

  Apenas una thread puede ejecutar una sección crítica en un momento dado. 

  *_Código_*
  ```c
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
  ```

  *Ejecución*
  #image("images/img_1752188867858.png")

  (b) Atomicidad
  ```c #pragma omp atomic
  <instrucción atómica>;
  ```
  Versión “light” de la sección crítica.

  Funciona apenas para una próxima instrucción de acceso a la memoria..

  *_Código_*

  ```c
  #include <stdio.h>
  #include <omp.h>

  int calc(int, int);

  int main() {
    int total, res = 0;
    #pragma omp parallel
    {
      #pragma omp master
      {
        printf("total de hilos: %d\n", omp_get_num_threads());
      }
      #pragma omp for
      for (int i = 0; i < omp_get_num_threads(); i++) {
        int id_t = omp_get_thread_num();
        #pragma omp atomic
        total += 2 * calc(id_t, i);
      }
    }

    printf("suma total = %d\n", total);

    return 0;
  }

  int calc(int id_t, int i) {
    return id_t + i;
  }
  ```

  *Ejecución*
  #image("images/img_1752188919024.png")
  
  (c) Barrera

  ```c #pragma omp barrier```

  barreras implícitas al final de las secciones paralelas! master. Se pueden provocar barreras.

  *_Código_*

  ```c
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
  ```

  *Ejecución*
  #image("images/img_1752188970922.png")

  *10. Funciones de biblioteca para _run-time_ para locks*

  ¿Son directivas?

  ```c omp_lock_t```, ```c omp_init_lock```, ```c omp_destroy_lock```,
  ```c omp_set_lock```, ```c omp_unset_lock```, ```c omp_test_lock```

  No, son funciones de la API de OpenMP que se llaman desde el código en tiempo de ejecución.
  - ```c omp_lock_t```: tipo de dato para definir un lock.

  - ```c omp_init_lock```: inicializa el lock.

  - ```c omp_set_lock```: adquiere el lock (bloquea si ya está ocupado).

  - ```c omp_unset_lock```: libera el lock.

  - ```c omp_test_lock```: intenta adquirir el lock sin bloquear.

  - ```c omp_destroy_lock```: destruye el lock.

  Explique qué ocurre en este código.

  #show raw.where(block: true): code => {
    show raw.line: line => {
      text(fill: gray)[#line.number]
      h(1em)
      line.body
    }
    code
  }
  ```c
  #include <stdio.h>
  #include <omp.h>

  omp_lock_t my_lock;

  int main() {
    omp_init_lock(&my_lock);

    #pragma omp parallel num_threads(4)
    {
      int tid = omp_get_thread_num();
      int i;

      for (i = 0; i < 5; ++i) {
        omp_set_lock(&my_lock);

        printf("Thread %d - starting locked region\n", tid);
        printf("Thread %d - ending locked region\n", tid);

        omp_unset_lock(&my_lock);
      }
    }

    omp_destroy_lock(&my_lock);
    return 0;
  }
  ```
  - Línea 4: Se crea la variable lock con el tipo ```c omp_lock_t```.
  - Línea 7: Se inicializa el lock.
  - Línea 9: Se inicia la sección paralela y se asignan 4 hilos.
  - Línea 11: Se obtiene el id del hilo actual.
  - Línea 12: Crea la variable i para el for.
  - Línea 14: Bloque for secuencial para cada hilo.
  - Línea 15: Se establece el lock para que solo un hilo pueda acceder a la región dentro del lock.
  - Línea 17 y 18: Se imprime mensaje de inicio y fin de la region bloqueada.
  - Línea 20: Se libera el lock.
  - Línea 24: Se destruye el lock.

  Lo que hace el código es crear una región bloqueada. Cada hilo intenta acceder a la región bloqueada que está controlada por un lock. El lock solo permite que un hilo acceda a la vez. Pero cada hilo intentará acceder 5 veces a esa región. Por lo tanto cada hilo hará 5 print de inicio y fin de la región bloqueada respectivamente.

  *Ejecución*
  #image("images/img_1751992715255.png")
]

