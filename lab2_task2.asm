; ===* Задание *===
; Написать программу, которая при первом нажатии кнопки включает лампочку, а при повторном -- выключаетс
; =================

.include "m8515def.inc" ;файл определений для ATmega8515

.def temp = r16
.def led = r20
.def buttonPressed = r21
.def lastPortState = r22
.def curPortState = r23

.equ TARGET_BUTTON = 3 ; Третья кнопка
.equ TARGET_LED = ~0b00000001 ; Будем включать первый светодиод


.org $000
	; Векторы прерываний
	rjmp INIT

; Инициализация
INIT:
	; Cброс led.0 для включения LED0
	ldi led, 0xFE

	; Установка указателя стека на последнюю ячейку ОЗУ
	ldi temp, $5F
	out SPL, temp
	ldi temp, $02
	out SPH, temp

	; Инициализация порта PB на вывод
	ser temp
	out DDRB, temp

	; Погасить светодиоды
	out PORTB, temp

	; Инициализация нужного вывода порта PD на ввод и подтягивающего резистора
	ldi temp, (1 << TARGET_BUTTON)
	out DDRD, temp
	out PORTD, temp

	; Инициализация флага состояния
	clr buttonPressed

	; Сохраняем значения из PIND
	in lastPortState, PIND

; Главная подпрограмма
MAIN:
	; Загружаем значения из PIND
	in curPortState, PIND

	; case TARGET_BUTTON
	sbrs curPortState, TARGET_BUTTON
	rcall ON_BUTTON_PRESSED

	; Сохраняем значения PIND
	mov lastPortState, curPortState

	; default
	rjmp MAIN

; Обработчик нажатия кнопки
ON_BUTTON_PRESSED:
	; Если кнопка была прожата и на прошлом такте, то ничего не делать
	sbrs lastPortState, TARGET_BUTTON
	ret

	; Если прожата кнопка -- выключаем лампочку
	sbrc buttonPressed, 0
	rjmp TRIGGER_LED_OFF

	; Иначе включаем
	rjmp TRIGGER_LED_ON

; Выключаем лампочку
TRIGGER_LED_OFF:
	ser led
	out PORTB, led

	; Инвертируем состояние
	clr buttonPressed

	; Выходим из обработчика
	ret

; Включаем лампочку
TRIGGER_LED_ON:
	ldi led, TARGET_LED
	out PORTB, led

	; Инвертируем состояние
	ser buttonPressed

	; Выходим из обработчика
	ret
