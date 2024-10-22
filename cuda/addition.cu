#include <stdio.h>
#include <cuda.h>
#define N 1

__global__ void add(int *a, int *b, int *c) {
    int index = threadIdx.x;
    if (index < N) {
        c[index] = a[index] + b[index];
    }
}

int main(void) {

    int *a, *b, *c; // Ponteiros para a memória do host
    int *d_a, *d_b, *d_c; // Ponteiros para a memória do dispositivo
    int size = N * sizeof(int);

    // Alocação de memória no host
    a = (int*)malloc(size);
    b = (int*)malloc(size);
    c = (int*)malloc(size);

    // Inicializando os arrays no host
    for (int i = 0; i < N; i++) {
        a[i] = 2; // Exemplo de valor
        b[i] = 7; // Exemplo de valor
    }

    // Alocação de memória no dispositivo
    cudaMalloc((void**)&d_a, size);
    cudaMalloc((void**)&d_b, size);
    cudaMalloc((void**)&d_c, size);

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
