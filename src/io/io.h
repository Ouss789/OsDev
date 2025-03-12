#ifndef IO_H
#define IO_H



unsigned char insb(unsigned short port); // this will read a byte from a given port
unsigned short insw(unsigned short port); // this will read a word from a given port

void outb(unsigned short port, unsigned char val); // this will write a byte to a given port
void outw(unsigned short port, unsigned short val); // this will write a word to a given port














#endif