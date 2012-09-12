//Pin to connect to the circuit
//Setting the pin LOW will tune the coil
//meaning it will respond as a high signal to the reader
//Setting the pin to HIGH will detune coil
//meaning the reader will see it as a low signal
int coil_pin = 9;

void setup()
{
  //Set pin as output
  pinMode(coil_pin, OUTPUT);
    
  //Start it as low
  digitalWrite(coil_pin, LOW);
}

void delay_cycles(int cycles) {
	delayMicroseconds(8 * cycles);
}


void baseband_zero()
{
	//this needs to be a toggle function
  	digitalWrite(coil_pin, LOW);
	delay_cycles(4);
	digitalWrite(coil_pin, HIGH);
	delay_cycles(4);
	digitalWrite(coil_pin, LOW);
	delay_cycles(4);
	digitalWrite(coil_pin, HIGH);
	delay_cycles(4);
	digitalWrite(coil_pin, LOW);
	delay_cycles(4);
	digitalWrite(coil_pin, HIGH);
	delay_cycles(4);
	digitalWrite(coil_pin, LOW);
	delay_cycles(4);
	digitalWrite(coil_pin, HIGH);
	delay_cycles(4);
	digitalWrite(coil_pin, LOW);
	delay_cycles(4);
	digitalWrite(coil_pin, HIGH);
	delay_cycles(4);
	digitalWrite(coil_pin, LOW);
	delay_cycles(4);
	digitalWrite(coil_pin, HIGH);
	delay_cycles(4);
	digitalWrite(coil_pin, LOW);
	delay_cycles(2);
}

void baseband_one()
{
	//this needs to be a toggle function
  	digitalWrite(coil_pin, LOW);
	delay_cycles(5);
	digitalWrite(coil_pin, HIGH);
	delay_cycles(5);
	digitalWrite(coil_pin, LOW);
	delay_cycles(5);
	digitalWrite(coil_pin, HIGH);
	delay_cycles(5);
	digitalWrite(coil_pin, LOW);
	delay_cycles(5);
	digitalWrite(coil_pin, HIGH);
	delay_cycles(5);
	digitalWrite(coil_pin, LOW);
	delay_cycles(5);
	digitalWrite(coil_pin, HIGH);
	delay_cycles(5);
	digitalWrite(coil_pin, LOW);
	delay_cycles(5);
	digitalWrite(coil_pin, HIGH);
	delay_cycles(5);
}

void baseband_one_last()
{
	//this needs to be a toggle function
  	digitalWrite(coil_pin, LOW);
	delay_cycles(5);
	digitalWrite(coil_pin, HIGH);
	delay_cycles(5);
	digitalWrite(coil_pin, LOW);
	delay_cycles(5);
	digitalWrite(coil_pin, HIGH);
	delay_cycles(5);
	digitalWrite(coil_pin, LOW);
	delay_cycles(5);
	digitalWrite(coil_pin, HIGH);
	delay_cycles(5);
	digitalWrite(coil_pin, LOW);
	delay_cycles(5);
	digitalWrite(coil_pin, HIGH);
	delay_cycles(5);
	digitalWrite(coil_pin, LOW);
	delay_cycles(5);
	digitalWrite(coil_pin, HIGH);
	delay_cycles(2);
}

void header() {
	baseband_zero();
	baseband_zero();
	baseband_zero();
	baseband_one();
	baseband_one();
	baseband_one();
}

void stop_bit() {
	baseband_zero();
	baseband_one_last();
}

void manchester_bit(int signal) {
	if (signal == 1) {
		baseband_one();
		baseband_zero();
	}
	else {
		baseband_zero();
		baseband_one();
	}
}

void loop()
{
  	//00001010		Decimal Site code of 10
	//0000010100011000	Unique ID of 1304


	header();
	baseband_zero();
	baseband_zero();
	baseband_zero();
	baseband_zero();
	baseband_one();
	baseband_zero();
	baseband_one();
	baseband_zero();

	baseband_zero();
	baseband_zero();
	baseband_zero();
	baseband_zero();
	baseband_zero();
	baseband_one();
	baseband_zero();
	baseband_one();
	baseband_zero();
	baseband_zero();
	baseband_zero();
	baseband_one();
	baseband_one();
	baseband_zero();
	baseband_zero();
	baseband_zero();
	stop_bit();

}
