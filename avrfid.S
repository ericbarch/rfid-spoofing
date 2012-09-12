/*
 * For the HID card:
 *   A 20-bit manufacturer code, 8-bit site code, and 16-bit unique ID, 1-bit odd parity.
 *
 * Manufacturer code is fixed. If modified, HID readers do not recognise the tag.
 * (This may also be a kind of fixed header.) Tested on HID readers with 26-bit wiegand output.
 */
	
#define HID_MFG_CODE        0x01002  // Do not modify
#define HID_SITE_CODE       0x0A     // Site code for apartment
#define HID_UNIQUE_ID       1303     // Eric's RFID Tag

/************ Common ************************************************/

#ifndef __ASSEMBLER__
#define __ASSEMBLER__
#endif
#include <avr/io.h>

.global main

#define OUT_PINS       _BV(PINB3) | _BV(PINB4)

    .macro	delay cycles
    .if \cycles > 1
    rjmp	.+0
    delay	(\cycles - 2)
    .elseif \cycles > 0
    nop
    delay	(\cycles - 1)
    .endif
    .endm

    .macro	manchester bit, count=1
    .if		\count
    manchester (\bit >> 1), (\count - 1)
    .if		\bit & 1
    baseband_1
    baseband_0
    .else
    baseband_0
    baseband_1
    .endif
    .endif
    .endm

    .macro	stop_bit
    baseband_0
    baseband_1_last
    .endm


/************ HID Implementation *********************************/

/*
 * This works with the HID 125 kHz prox cards I've tested it with,
 * but there are undoubtedly other formats used by HID. My cards are
 * marked with the model number "HID 0004H".
 *
 * These cards use both manchester encoding and FSK modulation. The FSK
 * modulation represents zeroes and ones using 4 and 5 full RF cycles, respectively.
 * An entire baseband bit lasts 50 RF cycles.
 *
 * Each packet begins with a header consisting of the baseband bit pattern "000111".
 * After that, we have 45 manchester-encoded bits before the packet repeats. The
 * last bit appears to be a stop bit, always zero. The previous 20 bits encode the
 * 6-digit unique ID, which is printed on the back of the card. The other 24 bits
 * have an unknown use. They could be a site code or manufacturing code. In the cards
 * I've examined, these bits are constant.
 */

#define ODD_PARITY(n)  ((( ((n) >> 0 ) ^ ((n) >> 1 ) ^ ((n) >> 2 ) ^ ((n) >> 3 ) ^ \
                           ((n) >> 4 ) ^ ((n) >> 5 ) ^ ((n) >> 6 ) ^ ((n) >> 7 ) ^ \
                           ((n) >> 8 ) ^ ((n) >> 9 ) ^ ((n) >> 10) ^ ((n) >> 11) ^ \
                           ((n) >> 12) ^ ((n) >> 13) ^ ((n) >> 14) ^ ((n) >> 15) ^ \
                           ((n) >> 16) ^ ((n) >> 17) ^ ((n) >> 18) ^ ((n) >> 19) ^ \
                           ((n) >> 20) ^ ((n) >> 21) ^ ((n) >> 22) ^ ((n) >> 23) ^ \
                           ((n) >> 24) ^ ((n) >> 25) ^ ((n) >> 26) ^ ((n) >> 27) ^ \
                           ((n) >> 28) ^ ((n) >> 29) ^ ((n) >> 30) ^ ((n) >> 31) ) & 1) ^ 1)
main:
        eor	r16, r16
        ldi	r17, OUT_PINS
loop:

        /*
         * Toggle the output modulation, in the specified number
         * of total clock cycles.
         */        
        .macro toggle clocks
        delay	(\clocks - 2)
        eor	r16, r17
        out	_SFR_IO_ADDR(DDRB), r16
        .endm
        
        /*
         * Emit a 0 at the baseband layer. (Toggle every 4 cycles, for 50 cycles)
	 * There was an rjmp that got us to the beginning of the loop, so drop
	 * 2 cycles from the delay if this is the first bit.  That will give the
	 * appropriate delay before the toggle.
	 *
	 * From observing the HID card, each 0 bit is either 48 or 52 cycles.
	 * The length alternates to keep the average at 50.  This keeps the
	 * waveform smooth, and keeps each bit in its 50 cycle time slot.
	 *
         * We don't have time for a function call, so we just chew
         * up lots of flash...
         */
        .macro	baseband_0
	.if startloop
	toggle	2		// 4
	.equ startloop, 0
	.else
        toggle	4		// 4
	.endif
        toggle	4		// 8
        toggle	4		// 12
        toggle	4		// 16
        toggle	4		// 20
        toggle	4		// 24
        toggle	4		// 28
        toggle	4		// 32
        toggle	4		// 36
        toggle	4		// 40
        toggle	4		// 44
        toggle	4		// 48
	.if evenzero
	.equ evenzero, 0
	.else
	toggle	4		// 52
	.equ evenzero, 1
	.endif
        .endm

        /*
         * Emit a 1 at the baseband layer. (Toggle every 5 cycles, for 50 cycles)
         */	
        .macro	baseband_1
	.if startloop
	toggle	3		// 4
	.equ startloop, 0
	.else
        toggle	5		// 4
	.endif
        toggle	5		// 10
        toggle	5		// 15
        toggle	5		// 20
        toggle	5		// 25
        toggle	5		// 30
        toggle	5		// 35
        toggle	5		// 40
        toggle	5		// 45
        toggle	5		// 50
        .endm

        .macro header
	.equ evenzero, 0
	.equ startloop, 1
        baseband_0
        baseband_0
        baseband_0
        baseband_1
        baseband_1
        baseband_1
        .endm


	/*
	 * This should add up to 45 bits.
	 *
	 * Some cards may use different 45-bit codes: For example,
	 * a Wiegand code, or something more site-specific. But the
	 * cards that I've seen use a 20-bit manufacturer code,
	 * 8-bit site code, 16-bit unique ID, and a single parity bit.
	 *
	 * If your card uses ad ifferent coding scheme, you can add,
	 * remove, and modify these 'manchester' macros. Just make sure
	 * the result adds up to the right number of bits.
	 */
        header
        manchester	HID_MFG_CODE, 20
	manchester	HID_SITE_CODE, 8
	manchester	HID_UNIQUE_ID, 16
	manchester	ODD_PARITY(HID_MFG_CODE ^ HID_SITE_CODE ^ HID_UNIQUE_ID), 1

        rjmp	loop