#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <parameter.h>

static uint32_t icache[CACHE_SIZE] = {};
static uint32_t tag[CACHE_SIZE] = {};

int main(int argc, char *argv[]){

    FILE *file = fopen(argv[1], "r");
    if (file == NULL) {
        perror("open .bin error!\n");
        return 1;
    }

    fseek(file, 0, SEEK_END);
    long file_size = ftell(file);
    fseek(file, 0, SEEK_SET);

    printf("size = %ld\n", file_size);

    if(file_size % sizeof(uint32_t) != 0){
        printf("size error!\n");
        return 1;
    }

    uint32_t* data = (uint32_t*)malloc(file_size);
    if (data == NULL) {
        printf("malloc error!\n");
        fclose(file);
        return 1;
    }

    int ret = fread(data, 1, file_size, file);

    for(int i = 0; i < 10; i++){
        printf("%08x\n", data[i]);
    }

    free(data);
    fclose(file);

    return 0;
}

