#include "config.h"

#include "memory.h"

#define SCREEN 0xB8000

void setc(int x, int y, char chr, char col)
{
    ((char*)(SCREEN + ((y*80+x)*2)))[0] = chr;
    ((char*)(SCREEN + ((y*80+x)*2)))[1] = col;
}

#define ROOT_MMAP_SIZE 128

MemoryMapEntry memory_map[ROOT_MMAP_SIZE];

int CursorX;
int CursorY;

void scroll()
{
    for(int i = 0;i < 24*80*2;i++)
    {
        ((char*)(SCREEN+i))[0] = ((char*)(SCREEN+i-160))[0];
    }
}

char globl_color = 0x0E;

void putc(char chr)
{
    if(chr != '\n'){
    setc(CursorX,CursorY,chr,globl_color);
    }
    CursorX++;
    if(CursorX >= 80 || chr == '\n')
    {
        CursorX = 0;
        CursorY++;
        if(CursorY >= 25)
        {
            scroll();
            CursorY--;
        }
    }
}

void puts(char* text)
{
    while(text[0] != 0)
    {
        putc(text[0]);
        text++;
    }
}

char* HEHXCHARS = "0123456789ABCDEF";

void puth(unsigned int value)
{
    if((value>>4))
    {
        puth(value>>4);
    }
    putc(HEHXCHARS[value&0xF]);
}

extern void cpuid_vstr(unsigned int ptr);

char* ello = "0123456789AB";

void AddMemEntry(void* base, void* len, unsigned short type)
{
    for(int i = 0;i < ROOT_MMAP_SIZE;i++)
    {
        if(memory_map[i].type == 0){
            memory_map[i].base = base;
            memory_map[i].len = len;
            memory_map[i].type = type;
            return;
        }
    }    
}

void entry(unsigned int grub_magic, unsigned int grub_addr)
{
    char* scrn = (char*)SCREEN;
    for(int i = 0;i < 80*25*2;i++)
    {
        scrn[i] = 0;
    }
    puts("Hello, Furries !!!\n");
    puts("This kernel is Unpaged !\n");
    puts("Probing Processor\n CPU ==> ");
    cpuid_vstr((unsigned int)ello);
    ello[12] = '\0';
    puts(ello);
    puts("\n");

    puts("Clearing MMAP\n");
    for(int i = 0;i < ROOT_MMAP_SIZE;i++)
    {
        memory_map[i].base = 0;
        memory_map[i].len = 0;
        memory_map[i].type = 0;
    }

    puts("Checking for bootlaoders\n");
    if(grub_magic == 0x2BADB002)
    {
        puts("GRUB Multiboot detected\n");
        unsigned int mmap_len = ((unsigned int*)(grub_addr+44))[0];
        unsigned int mmap_ptr = ((unsigned int*)(grub_addr+44))[1];

        puts(" --> Parsing mmap\n");

        for(int i = 0;i < mmap_len;)
        {
            unsigned int* mmap_dat = (unsigned int*)(mmap_ptr+i);
            if(mmap_dat[2] == 0)
            {
                AddMemEntry((void*)mmap_dat[1],(void*)mmap_dat[3],mmap_dat[5]);
            }
            puth(i);
            puts("ENTRY\n");
            i+= mmap_dat[0];
        }
    }

    while(1);
}