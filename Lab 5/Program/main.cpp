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

    scanf("%255[^\n]", input);

    input[strlen(input) - 1] = '\0';
    printf("Your string: '%s'\n", input);
    input[strlen(input)] = ' ';

    int nests = cmpwords(input, answer);
    printf("There are %d words in input string.\n", nests);

    puts("Result:");
    for (int i = 0; i < nests; i++) {
        printf("%d. %s\n", i + 1, answer[i]);

    }

    return 0;
}

void output(int number, char* word) {
    printf("Found %d similar to '%s' words.\n", number, word);
}
