#include <iostream>

extern int cmpwords(char* str, char** result);

int main(int argc, char *argv[])
{
    std::cout << "The following number is taken from assembly code:\n";

    char input[256];

    char **ptr;

    std::cout << cmpwords(input, ptr) << '\n';

    return 0;
}
