#include <cstdio>
#include <cstring>

const int maxNests = 16;
const int stringSize = 256;

extern int cmpwords(char *str, char result[maxNests][stringSize]);
void output(int, char*);

int main()
{
    puts("Enter the string:");

    char input[stringSize];
    char answer[maxNests][stringSize];

    //fgets(input, stringSize, stdin);
    strcpy(input, "12 12 13\n");

    input[strlen(input)-1] = 0;

    printf("Your string: '%s'\n", input);

    cmpwords(input, answer);

    printf("Result:\n%s\n", answer);

    return 0;
}

void output(int number, char* word) {
    printf("Found %d similar to '%s' words.\n", number, word);
}
