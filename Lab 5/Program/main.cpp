#include <cstdio>
#include <cstring>

extern int cmpwords(char *str, char *result[]);
void output(int, char*);

const int maxNests = 16;
const int stringSize = 256;

int main(int argc, char *argv[])
{
    puts("Enter the string:");

    char input[stringSize];
    char* nests[maxNests];
    char result[maxNests*stringSize] = {0};

    for (int i = 0; i < maxNests; i++) {
        nests[i] = result + i * stringSize;
    }

    //fgets(input, stringSize, stdin);
    strcpy(input, "12 12 13\n");

    input[strlen(input)-1] = 0;

    printf("Your string: '%s'\n", input);

    cmpwords(input, nests);

    printf("Result:\n%s\n", result);

    return 0;
}

void output(int number, char* word) {
    printf("Found %d similar to '%s' words.\n", number, word);
}
