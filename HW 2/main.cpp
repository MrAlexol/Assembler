#include <iostream>
#include <string>
#include <array>
#include <algorithm>
#include <cctype>

std::array<std::string, 25> functionWords = { "const", "record", "end", "char", "integer", "and", "array", "begin", "do", "else", "for", "if", "of", "or", "procedure"
                                             "program", "repeat", "then", "to", "until", "var", "while", "real", "string", "boolean" };
const char* delimiters = "+-?:;= */,)";

void integer(std::string& str) {
    std::string word = str.substr(0, str.find_first_of(delimiters));
    char sign = 0;
    if (word[0] == '+' || word[0] == '-') {
        sign = word[0];
        word.erase(0, 1);
        str.erase(0, 1);
    }
    for (auto chr : word)
    {
        if (!isdigit(chr)) throw std::string("The following lexeme is an integer: ").append(word);
    }
    std::cout << "Integer: " << sign << word << '\n';
    str.erase(0, word.length());
}


void ident(std::string& str) {
    std::string word = str.substr(0, str.find_first_of(delimiters));
    if (std::count(functionWords.begin(), functionWords.end(), word))
        throw std::string("The following lexeme is not identifier: ").append(word);
    if (isdigit(word[0])) throw std::string("The following lexeme is not identifier: ").append(word);
    for (auto chr : word)
    {
        if (!isalnum(chr)) throw std::string("The following lexeme is not identifier: ").append(word);
    }
    std::cout << "Identifier: " << word << '\n';
    str.erase(0, word.length());
}

void listOfIdent(std::string& str) {
    ident(str);
    str.erase(0, str.find_first_not_of(" ")); // skip spaces
    while (str[0] == ',') {
        str.erase(0, 1);
        str.erase(0, str.find_first_not_of(" ")); // skip spaces
        ident(str);
        str.erase(0, str.find_first_not_of(" ")); // skip spaces
    }
}

void constInit(std::string& str) {
    ident(str);
    str.erase(0, str.find_first_not_of(" ")); // skip spaces
    if (str[0] != ':') throw std::string("Wrong symbol. ':' expected ");
    str.erase(0, 1); // skip this lexeme
    str.erase(0, str.find_first_not_of(" ")); // skip spaces
    if (str[0] == '\'') {
        std::cout << "Char: " << str[1] << '\n';
        str.erase(0, 2);
        if (str[0] != '\'') throw std::string("Wrong symbol. ''' expected ");
        str.erase(0, 1);
    }
    else
        integer(str);
}

void listOfInit(std::string& str) {
    constInit(str);
    str.erase(0, str.find_first_not_of(" ")); // skip spaces
    while (str[0] == ';') {
        str.erase(0, 1);
        str.erase(0, str.find_first_not_of(" ")); // skip spaces
        constInit(str);
        str.erase(0, str.find_first_not_of(" ")); // skip spaces
    }
}

void fields(std::string& str) {
    if (str.substr(0, 3) == "end") {
        std::cout << "Function word: 'end'\n";
        str.erase(0, 3);
        return;
    }
    listOfIdent(str);
    str.erase(0, str.find_first_not_of(" ")); // skip spaces
    if (str[0] != ':') throw std::string("':' expected but '") + str[0] + "' found";
    str.erase(0, 1);
    str.erase(0, str.find_first_not_of(" ")); // skip spaces
    if (str.substr(0, str.find_first_of(delimiters)) == "char") {
        str.erase(0, 4);
    }
    else if (str.substr(0, str.find_first_of(delimiters)) == "integer") {
        str.erase(0, 7);
    }
    else
        throw std::string("Data type expected. Found ") + str.substr(0, str.find_first_of(delimiters));
    str.erase(0, str.find_first_not_of(" ")); // skip spaces
    if (str[0] == ';') {
        str.erase(0, 1); // skip semicolon
        str.erase(0, str.find_first_not_of(" ")); // skip spaces
        fields(str);
    }
    str.erase(0, str.find_first_not_of(" ")); // skip spaces
    if (str.substr(0, 3) == "end") {
        std::cout << "Function word: 'end'\n";
        str.erase(0, 3);
    }
}

void constRecord(std::string& str) {
    std::cout << "=====\nYour string: \"" << str << "\"\n";
    str.erase(0, str.find_first_not_of(" ")); // skip spaces
    std::transform(str.begin(), str.end(), str.begin(), [](unsigned char c) { return std::tolower(c); }); // to lowercase
    std::string word = str.substr(0, str.find(' '));
    if (word != "const") throw std::string("Wrong symbol: ").append(word);
    std::cout << "Function word: 'const'\n";
    str.erase(0, str.find(' ')); // skip this lexeme
    str.erase(0, str.find_first_not_of(" ")); // skip spaces
    
    ident(str);
    str.erase(0, str.find_first_not_of(" ")); // skip spaces

    if (str[0] != ':') throw std::string("Wrong symbol. ':' expected. Found ") + str.substr(0, str.find_first_of(delimiters));
    std::cout << "Symbol: ':'\n";
    str.erase(0, str.find(' ')); // skip this lexeme
    str.erase(0, str.find_first_not_of(" ")); // skip spaces

    word = str.substr(0, str.find(' '));
    if (word != "record") throw std::string("Wrong symbol: ").append(word);
    std::cout << "Function word: 'record'\n";
    str.erase(0, str.find(' ')); // skip this lexeme
    str.erase(0, str.find_first_not_of(" ")); // skip spaces

    fields(str);
    str.erase(0, str.find_first_not_of(" ")); // skip spaces
    
    if (str[0] != '=') throw std::string("Wrong symbol. '=' expected. Found ") + str.substr(0, str.find_first_of(delimiters));
    std::cout << "Symbol: '='\n";
    str.erase(0, str.find(' ')); // skip this lexeme
    str.erase(0, str.find_first_not_of(" ")); // skip spaces

    if (str[0] != '(') throw std::string("Wrong symbol. '(' expected. Found ") + str.substr(0, str.find_first_of(delimiters));
    std::cout << "Symbol: '('\n";
    str.erase(0, 1); // skip this lexeme
    str.erase(0, str.find_first_not_of(" ")); // skip spaces

    listOfInit(str);
    str.erase(0, str.find_first_not_of(" ")); // skip spaces
    if (str[0] != ')') throw std::string("Wrong symbol. ')' expected. Found ") + str.substr(0, str.find_first_of(delimiters));
}

int main()
{
    std::string input;

    while (std::cout << "Type the string\n", std::getline(std::cin, input), input != "end") {
        try {
            constRecord(input);
            std::cout << "== Correct" << std::endl;
        }
        catch (const char* msg) {
            std::cerr << msg << "\n== Incorrect" << std::endl;
        }
        catch (const std::string str) {
            std::cerr << str << "\n== Incorrect" << std::endl;
        }
        catch (...) {
            std::cout << "Unknown error\n";
        }
    }

    // system("pause"); on Windows
    // system("read"); on Linux
    return 0;
}

