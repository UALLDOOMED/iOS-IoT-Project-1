import smbus
import time

# Read sensor data
# from https://github.com/ControlEverythingCommunity/MPL3115A2/blob/master/Python/MPL3115A2.py
# and https://github.com/ControlEverythingCommunity/TCS34725/blob/master/Python/TCS34725.py

# Get I2C bus
bus = smbus.SMBus(1)

# MPL3115A2 address, 0x60(96)
# Select control register, 0x26(38)
#		0xB9(185)	Active mode, OSR = 128, Altimeter mode
# bus.write_byte_data(0x60, 0x26, 0xB9)
# MPL3115A2 address, 0x60(96)
# Select data configuration register, 0x13(19)
#		0x07(07)	Data ready event enabled for altitude, pressure, temperature
bus.write_byte_data(0x60, 0x13, 0x07)

# TCS34725 address, 0x29(41)
# Select Enable register, 0x80(128)
#		0x03(03)	Power ON, RGBC enable, RGBC Interrupt Mask not asserted
#					Wait disable, Sleep After Interrupt not asserted
bus.write_byte_data(0x29, 0x80, 0x03)
# TCS34725 address, 0x29(41)
# Select RGBC Timing register, 0x81(129)
#		0x00(00)	ATIME : 700ms
bus.write_byte_data(0x29, 0x81, 0x00)
# TCS34725 address, 0x29(41)
# Select Wait Time register, 0x83(131)
#		0xFF(255)	WTIME : 2.4ms
bus.write_byte_data(0x29, 0x83, 0xFF)
# TCS34725 address 0x29(41)
# Select Control register, 0x8F(143)
#		0x00(00)	AGAIN is 1x
bus.write_byte_data(0x29, 0x8F, 0x00)


def getSensorData():
    # MPL3115A2 address, 0x60(96)
    # Select control register, 0x26(38)
    #		0xB9(185)	Active mode, OSR = 128, Altimeter mode
    bus.write_byte_data(0x60, 0x26, 0xB9)

    # MPL3115A2 address, 0x60(96)
    # Read data back from 0x00(00), 6 bytes
    # status, tHeight MSB1, tHeight MSB, tHeight LSB, temp MSB, temp LSB
    MPL3115A2Data = bus.read_i2c_block_data(0x60, 0x00, 6)

    # TCS34725 address 0x29(41)
    # Read data back from 0x94(148), 8 bytes
    # cData LSB, cData MSB, Red LSB, Red MSB, Green LSB, Green MSB
    # Blue LSB, Blue MSB
    TCS34725Data = bus.read_i2c_block_data(0x29, 0x94, 8)

    temp = ((MPL3115A2Data[4] * 256) + (MPL3115A2Data[5] & 0xF0)) / 16
    cTemp = temp / 16.0

    # MPL3115A2 address, 0x60(96)
    # Select control register, 0x26(38)
    #		0x39(57)	Active mode, OSR = 128, Barometer mode
    bus.write_byte_data(0x60, 0x26, 0x39)

    time.sleep(1)

    # MPL3115A2 address, 0x60(96)
    # Read data back from 0x00(00), 4 bytes
    # status, pres MSB1, pres MSB, pres LSB
    MPL3115A2Data = bus.read_i2c_block_data(0x60, 0x00, 4)

    # Convert the data to 20-bits
    pres = ((MPL3115A2Data[1] * 65536) + (MPL3115A2Data[2]
                                          * 256) + (MPL3115A2Data[3] & 0xF0)) / 16
    pressure = (pres / 4.0) / 1000.0

    # Convert the data
    cData = TCS34725Data[1] * 256 + TCS34725Data[0]
    red = TCS34725Data[3] * 256 + TCS34725Data[2]
    green = TCS34725Data[5] * 256 + TCS34725Data[4]
    blue = TCS34725Data[7] * 256 + TCS34725Data[6]

    # Calculate luminance
    luminance = (-0.32466 * red) + (1.57837 * green) + (-0.73191 * blue)

    # # Output data to screen
    # print("Pressure : %.2f kPa" % pressure)
    # print("Temperature in Celsius  : %.2f C" % cTemp)
    # # Output data to screen
    # print(round(red ** 0.5), round(green ** 0.5), round(blue ** 0.5))
    # print("IR luminance : %d lux" % cData)
    # print("Ambient Light luminance : %.2f lux" % luminance)
    # print()
    return [pressure, cTemp, red ** 0.5, green ** 0.5, blue ** 0.5, cData, luminance]
