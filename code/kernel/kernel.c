
void __attribute__((cdecl)) start()
{
        int a = 5;
        int b = 10;
        int c = a+b;
        char* x = 0xb8000;
	*x = 'X';
	
	for(;;);

}
