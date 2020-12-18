#!/usr/bin/python
# -*- coding: utf-8 -*-

try:
  import zxing
except ImportError:
  print("Please install required module: zxing. \n")

import zxing
import re
import pandas as pd
import os
import requests

# Print Colors
class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def Scan_Boarding_Pass( image_here ):
    # Creating a BarcodeReader object
    reader = zxing.BarCodeReader()

    if image_here.startswith("http"):
        ## Download Image from URL
        with open('bar_image.png', 'wb') as handle:
            response = requests.get(image_here, stream=True)
            if not response.ok:
                print(response)
            for block in response.iter_content(1024):
                if not block:
                    break
                handle.write(block)
        # Path to downloaded Image
        image_path = os.getcwd() + "/bar_image.png"
    else:
        image_path = image_here.strip()

    # Decoding the image passed to the method of the object
    mytext = reader.decode(image_path)

    # Format division
    BarCode_Format = mytext.format
    BarCode_Raw = mytext.raw
    BarCode_Raw = BarCode_Raw.upper()

    # Bar Code Type
    if BarCode_Format == 'AZTEC':
        BarCode_Format = 'AZTEC – QR Code'
    elif BarCode_Format == 'PDF_417':
        BarCode_Format = 'PDF_417 – Print'
    else:
        raise SystemExit("Wrong bar code format!")

    # Condition
    if len(BarCode_Raw) < 50:
        print('This is not a Boarding Pass.')
        raise Exception('The {} does not seem to be a Boarding Pass'.format(BarCode_Format))
        raise SystemExit("Wrong bar code format!")

    #BarCode_Points = mytext.points

    ## PASSENGER NAME ##
    try:
        # Extract Information
        BarCode_Raw_divided = BarCode_Raw.split()
        BarCode_Raw_divided

        # Passenger Name Information
        Passenger_Name_LastName = BarCode_Raw.split("/")[0]
        Passenger_Name_LastName = Passenger_Name_LastName.strip("M1")
        Passenger_Name_FirstName = BarCode_Raw_divided[0].split("/")[1]
        # Concatenation
        Passenger_Name = Passenger_Name_FirstName + " " + Passenger_Name_LastName
    except:
        Passenger_Name = "NONE"
        print("The passanger Name could not be located.\n")

    ## RESERVATION NUMBER ##
    try:
        # Reservation Number Information
        Reservation_Number = BarCode_Raw_divided[1]
        if Reservation_Number.startswith('E'):
            Reservation_Number = Reservation_Number.strip("E")
    except:
        Reservation_Number = "NONE"
        print("The Reservation Number could not be located.\n")

    ## FLIGHT AIRLINE ##
    try:
        # Flight Information
        if len(BarCode_Raw_divided[2]) == 8:
            Flight_Airport = BarCode_Raw_divided[2]
        else:
            Flight_Airport = BarCode_Raw_divided[3]
        n = 3
        Flight_Airport = [Flight_Airport[i:i+n] for i in range(0, len(Flight_Airport), n)]
        Flight_Airport_Departure = Flight_Airport[0]
        Flight_Airport_Destination = Flight_Airport[1]
        Flight_Airline = Flight_Airport[2]

        ###############################
        #         DATAFRAME 1         #
        ###############################
        # SOURCE: https://openflights.org/data.html
        df = pd.read_table(external_data.airports_dat,  # External data
                           sep=",",
                           names=['1','Name','City','Country','IATA','ICAO','Latitude','Longitude','Altitude','Timezone','DST','Tz_DB','Type','Source'])
        df.drop(['1','Altitude','Timezone','DST','Tz_DB','Type','Source'], axis=1, inplace=True)

        # Count NAs
        #df.isnull().sum()
        # Frequency of values in column
        #df['Type'].value_counts()

        # Clean up
        df['IATA'] = df['IATA'].map(lambda x: re.sub(r'\W+', 'NaN', x))
        df = df.replace(r'\\N', 'NaN', regex=True)
        df = df.replace(r'NaNN', 'NaN', regex=True)
        df = df.replace('NaN', '', regex=True)
        df.fillna('', inplace=True)

        # More Information
        # Flight Destination Information
        row = df.loc[df['IATA'] == Flight_Airport_Departure]
        Flight_Airport_Departure_Name = row['Name'].values[0]

        # Flight Destination Information
        row = df.loc[df['IATA'] == Flight_Airport_Destination]
        Flight_Airport_Destination_Name = row['Name'].values[0]
        ###############################
        #          END DF 1           #
        ###############################
        ###############################
        #         DATAFRAME 2         #
        ###############################
        df2 = pd.read_table(external_data.airlines_dat,  # External data
                            sep=",",
                            names=['1','Airline','Name','Alias','IATA','ICAO','Callsign','Country','Active'])
        df2.drop(['1','IATA','ICAO','Callsign','Country','Active'], axis=1, inplace=True)

        # Clean up
        df2 = df2.replace(r'\\N', 'NaN', regex=True)
        df2 = df2.replace('NaN', '', regex=True)
        df2.fillna('', inplace=True)

        # More Information
        # Airline Name Information
        row = df2.loc[df2['Alias'] == Flight_Airline]
        Flight_Airline_Name = row['Airline'].values[0]
        ###############################
        #          END DF 2           #
        ###############################
    except:
        Flight_Airline = "NONE"
        Flight_Airport_Departure_Name = "NONE"
        Flight_Airport_Destination_Name = "NONE"
        Flight_Airline_Name = "NONE"
        print("The Airline, Departure and Destination info could not be located.\n")

    try:
        # Condition for more Info
        if len(BarCode_Raw_divided) > 5:
            More_Info = BarCode_Raw_divided[4]
            # More Information
            # Flight Number
            Flight_Number = BarCode_Raw_divided[3]
            # Flight Date
            Date_of_Flight = More_Info[:3]
            Date_of_Flight_Month = Date_of_Flight[0]
            Date_of_Flight_Day = Date_of_Flight[1:3]
            # Seat Number
            Seat_Number = More_Info.replace(Date_of_Flight,"")
            Seat_Number = Seat_Number[1:5]
        else:
            More_Info = BarCode_Raw_divided[3]
            # More Information
            # Flight Number
            Flight_Number = More_Info[:5]
            # Flight Date
            Date_of_Flight = More_Info.replace(Flight_Number,"")
            Date_of_Flight = Date_of_Flight[:3]
            Date_of_Flight_Month = Date_of_Flight[:1]
            Date_of_Flight_Day = Date_of_Flight[1:]
            # Seat Number
            Seat_Number = More_Info.replace(Flight_Number,"")
            Seat_Number = Seat_Number.replace(Date_of_Flight,"")
            Seat_Number = Seat_Number[1:5]
    except:
        Flight_Number = "00000"
        Date_of_Flight = "000000"
        Seat_Number = "NA"
        print("Flight number, Seat, and Date could not be located.\n")

    # Formatting
    if Date_of_Flight_Month == '0':
        Date_of_Flight_Month = '1'
    if Flight_Number.startswith('00'):
        Flight_Number = Flight_Number.strip("00")

    Date_of_Flight_Month = int(Date_of_Flight_Month)
    Date_of_Flight_Day = int(Date_of_Flight_Day)

    if Date_of_Flight_Month > 12:
        Date_of_Flight_Month = 'Err'
    if Date_of_Flight_Day > 31:
        Date_of_Flight_Day = 'Err'
    if Seat_Number.startswith('00'):
        Seat_Number = Seat_Number.strip("00")

    ###############################
    #          PRINTING           #
    ###############################
    # Print
    print("\n")
    print(f"{bcolors.OKBLUE} ################################################################## {bcolors.ENDC}")
    print("\n")

    print(" BarCode Type: ", BarCode_Format)
    BarCode_Raw = " ".join(BarCode_Raw.split())
    print(" Raw Text: ", BarCode_Raw, "\n")

    print(f" Passenger Name: {bcolors.BOLD}", f"{bcolors.OKGREEN}", Passenger_Name, f"{bcolors.ENDC} ", f"{bcolors.ENDC} ")
    print(f" Reservation Number: {bcolors.OKGREEN}", Reservation_Number, f"{bcolors.ENDC} \n")
    print(" Departure Airport: ",Flight_Airport_Departure_Name,"(" + Flight_Airport_Departure + ")")
    print(" Destination Airport: ", Flight_Airport_Destination_Name,"(" + Flight_Airport_Destination + ")", "\n")

    print(" Airline: ", Flight_Airline_Name)
    print(f" Flight Number: {bcolors.OKGREEN}", Flight_Airline + Flight_Number, f"{bcolors.ENDC}")
    print(" Seat: ", Seat_Number)
    print(" Day/Month: ", Date_of_Flight_Day, "/", Date_of_Flight_Month, "\n")

    print("\n")
    print(f"{bcolors.OKBLUE} ################################################################## {bcolors.ENDC}")
    print("\n")
    #print("Points:", BarCode_Points)

# Image of the Boarding Pass Bar Code
image_path = input("Image Path: ")
Scan_Boarding_Pass(image_path)
