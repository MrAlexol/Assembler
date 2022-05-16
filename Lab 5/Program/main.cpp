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
    strcpy(input, "proza pruza pruzo proz rproza ");

    //input[strlen(input)-1] = 0;

    printf("Your string: '%s'\n", input);

    cmpwords(input, answer);

    puts("Result:");
    int nestNo = 0;
    while (answer[nestNo][0] != '\0') {
        printf("%s\n", answer[nestNo]);
        nestNo++;
    }
    return 0;
}

void output(int number, char* word) {
    printf("Found %d similar to '%s' words.\n", number, word);
}
