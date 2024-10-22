#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N 12

void random_ints(int *array, int size) {
    for (int i = 0; i < size; i++) {
        array[i] = rand() % 100; // Gera números aleatórios entre 0 e 99
    }
}

__global__ void add(int *a, int *b, int *c) {
    int index = threadIdx.x;
    if (index < N) {
        c[index] = a[index] + b[index];
    }
}

int main(void) {
    int *a, *b, *c;
    int *d_a, *d_b, *d_c;
    int size = N * sizeof(int);

    // Inicializa a semente para números aleatórios
    srand(time(NULL));

    // Alocação de memória no host
    a = (int *)malloc(size);
    random_ints(a, N);
    b = (int *)malloc(size);
    random_ints(b, N);
    c = (int *)malloc(size);

    // Alocação de memória no dispositivo
    cudaMalloc((void **)&d_a, size);
    cudaMalloc((void **)&d_b, size);
    cudaMalloc((void **)&d_c, size);

    // Cópia dos dados do host para o dispositivo
    cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);

    // Chamada do kernel com N threads
    add<<<1, N>>>(d_a, d_b, d_c);

    // Cópia dos resultados do dispositivo para o host
    cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);

    // Exibir os resultados
    for (int i = 0; i < N; i++) {
        printf("%d + %d = %d\n", a[i], b[i], c[i]);
    }

    // Liberação da memória
    free(a);
    free(b);
    free(c);
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    return 0;
}
