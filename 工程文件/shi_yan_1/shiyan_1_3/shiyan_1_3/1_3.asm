.686
.model flat, stdcall
ExitProcess PROTO : DWORD
includelib  kernel32.lib; ExitProcess �� kernel32.lib��ʵ��
printf          PROTO C : VARARG
includelib  libcmt.lib
includelib  legacy_stdio_definitions.lib
scanf    PROTO C : dword, : vararg

.DATA
password db 'bestfriend', 0
buf1 db 'OK!', 0
buf2 db 'Incorrect Password!', 0
buf3 db '����һ���10λ���ַ�������:', 0
lpFmt	db	"%s", 0ah, 0dh, 0
format2 db '%s', 0; ����scanf������ʽ������.
value db 11 dup(0); �洢scanf�õ����û�����

.STACK 200

.CODE
main proc c
invoke printf, offset lpFmt, offset buf3
invoke scanf, offset format2, offset value
mov ecx, 0

L1:
mov eax, offset value
mov bl, password[ecx]
cmp bl, [eax + ecx]
jnz Exit
inc ecx
cmp ecx, 10
jle L1

invoke printf, offset lpFmt, offset buf1
invoke ExitProcess, 0

Exit:
invoke printf, offset lpFmt, offset buf2
invoke ExitProcess, 0
main endp
END
