; ===* ������� *===
; �������� ���������, ������� ��� ������ ������� ������ �������� ��������, � ��� ��������� -- ����������
; =================

.include "m8515def.inc" ;���� ����������� ��� ATmega8515

.def temp = r16
.def led = r20
.def buttonPressed = r21
.def lastPortState = r22
.def curPortState = r23

.equ TARGET_BUTTON = 3 ; ������ ������
.equ TARGET_LED = ~0b00000001 ; ����� �������� ������ ���������


.org $000
	; ������� ����������
	rjmp INIT

; �������������
INIT:
	; C���� led.0 ��� ��������� LED0
	ldi led, 0xFE

	; ��������� ��������� ����� �� ��������� ������ ���
	ldi temp, $5F
	out SPL, temp
	ldi temp, $02
	out SPH, temp

	; ������������� ����� PB �� �����
	ser temp
	out DDRB, temp

	; �������� ����������
	out PORTB, temp

	; ������������� ������� ������ ����� PD �� ���� � �������������� ���������
	ldi temp, (1 << TARGET_BUTTON)
	out DDRD, temp
	out PORTD, temp

	; ������������� ����� ���������
	clr buttonPressed

	; ��������� �������� �� PIND
	in lastPortState, PIND

; ������� ������������
MAIN:
	; ��������� �������� �� PIND
	in curPortState, PIND

	; case TARGET_BUTTON
	sbrs curPortState, TARGET_BUTTON
	rcall ON_BUTTON_PRESSED

	; ��������� �������� PIND
	mov lastPortState, curPortState

	; default
	rjmp MAIN

; ���������� ������� ������
ON_BUTTON_PRESSED:
	; ���� ������ ���� ������� � �� ������� �����, �� ������ �� ������
	sbrs lastPortState, TARGET_BUTTON
	ret

	; ���� ������� ������ -- ��������� ��������
	sbrc buttonPressed, 0
	rjmp TRIGGER_LED_OFF

	; ����� ��������
	rjmp TRIGGER_LED_ON

; ��������� ��������
TRIGGER_LED_OFF:
	ser led
	out PORTB, led

	; ����������� ���������
	clr buttonPressed

	; ������� �� �����������
	ret

; �������� ��������
TRIGGER_LED_ON:
	ldi led, TARGET_LED
	out PORTB, led

	; ����������� ���������
	ser buttonPressed

	; ������� �� �����������
	ret
