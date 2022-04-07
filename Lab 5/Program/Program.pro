QT -= gui

CONFIG += c++11 console
CONFIG -= app_bundle

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0
#DEFINES += QT_DEPRECATED_WARNINGS

SOURCES += main.cpp
OBJECTS += text.o # my assembly code
DISTFILES += text.asm

CONFIG ~= s/-O[0123s]//g # no optimisation
CONFIG += -O0
