bits 32

section .entry
global entry
extern start

entry:
	
	
	call start
	hlt
