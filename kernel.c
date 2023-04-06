#include "printf.h"
#include "screen.h"
#include "types.h"
#include "pci.h"



void error(void)
{
	char *vidptr = (char*)0xb8000;
	unsigned int i = 0;
	unsigned int j = 0;

	int _err = 7;
	const char *str = _err ? "!!! ... error ... !!!" : "!!! ... debug ... !!!" ;

	while (str[j] != '\0') {
		vidptr[i] = str[j];
		vidptr[i+1] = 0x13;
		++j;
		i = i + 2;
	}


	
}


void kmain(void)
{   
    clear_screen();
    printf("\n -------- test: KERNEL-1 -------\n");

    PCIScan();

    error();


}







/*
void kmain(void)
{
	const char *str = "kernel-1";
	char *vidptr = (char*)0xb8000;
	unsigned int i = 0;
	unsigned int j = 0;
	unsigned int screensize;

	screensize = 80 * 25 * 2;
	while (j < screensize) {
		vidptr[j] = ' ';
		vidptr[j+1] = 0x07;
		j = j + 2;
	}

	j = 0;

	while (str[j] != '\0') {
		vidptr[i] = str[j];
		vidptr[i+1] = 0x07;
		++j;
		i = i + 2;
	}

	return;
}

*/