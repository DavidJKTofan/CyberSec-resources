# Install packages
# pip install pandas pyzbar pillow requests pdf417decoder

import os
import re
import pandas as pd
import requests
import argparse
from PIL import Image
from pdf417decoder import PDF417Decoder
from pyzbar.pyzbar import decode
from datetime import datetime

# Function to load and clean the DAT files (airports and airlines)
def load_and_clean_dat_files():
    # Paths for the DAT files
    airports_file = os.path.join(os.getcwd(), 'External_Data', 'airports.dat')
    airlines_file = os.path.join(os.getcwd(), 'External_Data', 'airlines.dat')

    # Load airports.dat file
    df_airports = pd.read_csv(airports_file, header=None, quotechar='"')
    df_airports.columns = ['Index', 'Name', 'City', 'Country', 'IATA', 'ICAO', 'Latitude', 'Longitude', 'Altitude', 'Timezone', 'DST', 'Tz_DB', 'Type', 'Source']
    
    # Clean the airports dataframe
    df_airports['IATA'] = df_airports['IATA'].map(lambda x: re.sub(r'\\W+', 'NaN', str(x)))
    df_airports = df_airports.replace(r'\\\\N', 'NaN', regex=True)
    df_airports = df_airports.replace(r'NaNN', 'NaN', regex=True)
    df_airports = df_airports.replace('NaN', '', regex=True)
    df_airports.fillna('', inplace=True)

    # Load airlines.dat file
    df_airlines = pd.read_csv(airlines_file, header=None, quotechar='"')
    df_airlines.columns = ['Index', 'Airline', 'Alias', 'IATA', 'ICAO', 'Callsign', 'Country', 'Active']
    
    # Clean the airlines dataframe
    df_airlines.replace(r'\\\\N', 'NaN', regex=True, inplace=True)
    df_airlines.replace('NaN', '', regex=True, inplace=True)
    df_airlines.fillna('', inplace=True)
    
    return df_airports, df_airlines

# Function to decode a barcode using pdf417decoder or pyzbar
def decode_barcode(image_path):
    try:
        # Try decoding with pdf417decoder
        img = Image.open(image_path)
        decoder = PDF417Decoder(img)
        if decoder.decode() > 0:
            return 'PDF417', decoder.barcode_data_index_to_string(0).strip()
    except Exception as e:
        print(f"Error with pdf417decoder: {e}")

    try:
        # Fallback to pyzbar (for QR, QRCode, or other barcodes)
        img = Image.open(image_path)
        decoded_objects = decode(img)
        if decoded_objects:
            # Iterate through all detected barcodes and check their types
            for obj in decoded_objects:
                barcode_type = obj.type
                decoded_data = obj.data.decode('utf-8').strip()

                if barcode_type == 'QRCODE':
                    print("\nQR Code detected.")
                    return 'QR', decoded_data
                elif barcode_type == 'AZTEC':
                    print("\nAztec Barcode detected.")
                    return 'AZTEC', decoded_data
                else:
                    print("ERROR!")
                    return barcode_type, decoded_data
    except Exception as e:
        print(f"Error with pyzbar: {e}")

    return None, None

# Function to convert Julian date to Gregorian date
def julian_date_to_gregorian(julian_date):
    try:
        # Julian date is in the format of 3 digits, e.g., '319' for the 319th day of the year
        day_of_year = int(julian_date)
        year = datetime.now().year  # Assume the current year

        # Convert the Julian date to a Gregorian date
        gregorian_date = datetime(year, 1, 1) + pd.Timedelta(days=day_of_year - 1)

        # Format the date as Month Dayth (e.g., "December 8th")
        return gregorian_date.strftime("%B %dth")
    except Exception as e:
        print(f"Error converting Julian date to Gregorian: {e}")
        return "UNKNOWN"

# Function to parse PDF417 barcode data into boarding pass details
def parse_pdf417_boarding_pass(barcode_data, df_airports, df_airlines):
    fields = barcode_data.split()

    # Extract Passenger Name (Field 11)
    try:
        if "/" in fields[0]:
            name_parts = fields[0].split("/")
            passenger_name_first = name_parts[1].strip()
            passenger_name_last = name_parts[0].strip("M1")
            Passenger_Name = f"{passenger_name_first} {passenger_name_last}"
        else:
            Passenger_Name = "UNKNOWN"
    except Exception as e:
        Passenger_Name = "UNKNOWN"
        print(f"Error extracting passenger name: {e}")

    # Extract Reservation Number (Field 1)
    try:
        Reservation_Number = fields[1].strip()[1:]
    except Exception as e:
        Reservation_Number = "UNKNOWN"
        print(f"Error extracting reservation number: {e}")

    # Extract Departure and Destination Airports (Field 2)
    try:
        airport_codes = fields[2]  # GVALHRBA
        Departure_Airport = airport_codes[:3]  # GVA
        Destination_Airport = airport_codes[3:6]  # LHR
    except Exception as e:
        Departure_Airport = "UNKNOWN"
        Destination_Airport = "UNKNOWN"
        print(f"Error extracting airport codes: {e}")
    
    # Lookup airport names
    try:
        departure_airport = df_airports.loc[df_airports['IATA'] == Departure_Airport]
        Departure_Airport_Name = departure_airport['Name'].values[0] if not departure_airport.empty else "UNKNOWN"
        
        destination_airport = df_airports.loc[df_airports['IATA'] == Destination_Airport]
        Destination_Airport_Name = destination_airport['Name'].values[0] if not destination_airport.empty else "UNKNOWN"
    except Exception as e:
        print(f"Error fetching airport details: {e}")
        Departure_Airport_Name = "UNKNOWN"
        Destination_Airport_Name = "UNKNOWN"

    # Extract Airline Code and Flight Number (Field 2/3)
    try:
        airline_code = airport_codes[6:8]  # BA from GVALHRBA
        Flight_Number = fields[3][:5]  # 00723 from 00723319
    except Exception as e:
        airline_code = "UNKNOWN"
        Flight_Number = "UNKNOWN"
        print(f"Error extracting airline code and flight number: {e}")

    # Lookup airline name
    try:
        airline = df_airlines.loc[df_airlines['IATA'] == airline_code]
        Airline_Name = airline['Airline'].values[0] if not airline.empty else "UNKNOWN"
    except Exception as e:
        Airline_Name = "UNKNOWN"
        print(f"Error fetching airline details: {e}")

    # Extract Flight Date (From 6th, 7th, and 8th characters)
    try:
        flight_data = fields[3]  # 00723319C002F00009100
        julian_date_code = flight_data[5:8]  # Extract Julian date (319)
        Flight_Date = julian_date_to_gregorian(julian_date_code)
    except:
        Flight_Date = "UNKNOWN"
        print("Error extracting flight date.\n")

    # Extract Seat Information (From 9th to 12th characters)
    try:
        seat_code = flight_data[8:13]  # Extract seat code (C002F)
        if len(seat_code) >= 5:  # Ensure the seat code is long enough
            Seat_Number = str(int(seat_code[1:4])) + seat_code[4]  # Row and Seat letter
        else:
            Seat_Number = "UNKNOWN"
    except:
        Seat_Number = "UNKNOWN"
        print("Error extracting seat number.\n")

    # Return parsed boarding pass details
    return {
        'passenger_name': Passenger_Name,
        'reservation_number': Reservation_Number,
        'departure_airport': Departure_Airport,
        'departure_airport_name': Departure_Airport_Name,
        'destination_airport': Destination_Airport,
        'destination_airport_name': Destination_Airport_Name,
        'airline': airline_code,
        'airline_name': Airline_Name,
        'flight_number': Flight_Number,
        'flight_date': Flight_Date,
        'seat_number': Seat_Number,
        #'raw_barcode': barcode_data  # DEBUGGING
    }

# Function to parse QRCode data into boarding pass details
def parse_qrcode_boarding_pass(barcode_data, df_airports, df_airlines):
    fields = barcode_data.split()

    # Extract Passenger Name (Field 11)
    try:
        if "/" in fields[0]:
            name_parts = fields[0].split("/")
            passenger_name_first = name_parts[1].strip()
            passenger_name_last = name_parts[0].strip("M1")  # Adjust for 'M1' at the start
            Passenger_Name = f"{passenger_name_first} {passenger_name_last}"
        else:
            Passenger_Name = "UNKNOWN"
    except Exception as e:
        Passenger_Name = "UNKNOWN"
        print(f"Error extracting passenger name: {e}")

    # Extract Reservation Number (Field 1)
    try:
        Reservation_Number = fields[1].strip()  # This can have more than 5 chars
    except Exception as e:
        Reservation_Number = "UNKNOWN"
        print(f"Error extracting reservation number: {e}")

    # Extract Departure and Destination Airports (Field 2)
    try:
        airport_codes = fields[2]  # CNFRECAD
        Departure_Airport = airport_codes[:3]  # CNF
        Destination_Airport = airport_codes[3:6]  # REC
    except Exception as e:
        Departure_Airport = "UNKNOWN"
        Destination_Airport = "UNKNOWN"
        print(f"Error extracting airport codes: {e}")
    
    # Lookup airport names
    try:
        departure_airport = df_airports.loc[df_airports['IATA'] == Departure_Airport]
        Departure_Airport_Name = departure_airport['Name'].values[0] if not departure_airport.empty else "UNKNOWN"
        
        destination_airport = df_airports.loc[df_airports['IATA'] == Destination_Airport]
        Destination_Airport_Name = destination_airport['Name'].values[0] if not destination_airport.empty else "UNKNOWN"
    except Exception as e:
        print(f"Error fetching airport details: {e}")
        Departure_Airport_Name = "UNKNOWN"
        Destination_Airport_Name = "UNKNOWN"

    # Extract Airline Code and Flight Number (Field 2/3)
    try:
        airline_code = "AD"  # Azul Brazilian Airlines (AD)
        Flight_Number = fields[3][:4]  # Flight number is at the start of the field (4178)
    except Exception as e:
        airline_code = "UNKNOWN"
        Flight_Number = "UNKNOWN"
        print(f"Error extracting airline code and flight number: {e}")

    # Lookup airline name
    try:
        airline = df_airlines.loc[df_airlines['IATA'] == airline_code]
        Airline_Name = airline['Airline'].values[0] if not airline.empty else "UNKNOWN"
    except Exception as e:
        Airline_Name = "UNKNOWN"
        print(f"Error fetching airline details: {e}")

    # Flight Date (Julian Date - Field 4)
    try:
        julian_date_code = fields[4][:3]  # Julian date is 3 digits (e.g., '141')
        Flight_Date = julian_date_to_gregorian(julian_date_code)  # Convert to Gregorian date
    except Exception as e:
        Flight_Date = "UNKNOWN"
        print(f"Error extracting flight date: {e}")

    # Extract Seat Information (Field 5 or elsewhere in the barcode)
    try:
        seat_code = fields[4][3:8]  # Seat code (e.g., 008A)
        
        # Ensure we strip out any unwanted characters like 'Y'
        Seat_Number = seat_code.lstrip('Y')  # Remove leading 'Y' if present

        if len(Seat_Number) >= 4:  # Ensure the seat code is long enough
            # Extract row and seat letter (e.g., '008A')
            Seat_Number = str(int(Seat_Number[:3])) + Seat_Number[3]  # e.g., '008A'
        else:
            Seat_Number = "UNKNOWN"
    except Exception as e:
        Seat_Number = "UNKNOWN"
        print(f"Error extracting seat number: {e}")

    # Return parsed boarding pass details
    return {
        'passenger_name': Passenger_Name,
        'reservation_number': Reservation_Number,
        'departure_airport': Departure_Airport,
        'departure_airport_name': Departure_Airport_Name,
        'destination_airport': Destination_Airport,
        'destination_airport_name': Destination_Airport_Name,
        'airline': airline_code,
        'airline_name': Airline_Name,
        'flight_number': Flight_Number,
        'flight_date': Flight_Date,
        'seat_number': Seat_Number,
        #'raw_barcode': barcode_data # DEBUGGING
    }

# Function to scan boarding pass from image source (URL or file path)
def scan_boarding_pass(image_here):
    # If the input is a URL, download the image
    if isinstance(image_here, str) and image_here.startswith("https://"):
        image_path = 'boarding_pass_image.png'
        with open(image_path, 'wb') as handle:
            response = requests.get(image_here, stream=True)
            if response.ok:
                for block in response.iter_content(1024):
                    if not block:
                        break
                    handle.write(block)
        image_here = os.path.join(os.getcwd(), image_path)

    # Decode the barcode data and type
    barcode_type, barcode_data = decode_barcode(image_here)

    if not barcode_data:
        print("Error decoding the barcode.")
        print(f"Barcode Type: {barcode_type}\n")
        #print(barcode_data) # DEBUGGING
        return

    print(f"\nBarcode Type: {barcode_type}")
    print(f"\nRaw Barcode Data: {barcode_data}\n")

    # Load and clean the DAT files
    df_airports, df_airlines = load_and_clean_dat_files()

    # Parse the barcode data based on barcode type
    if barcode_type == 'PDF417':
        boarding_pass_details = parse_pdf417_boarding_pass(barcode_data, df_airports, df_airlines)
    elif barcode_type == 'QR': # QRCode
        boarding_pass_details = parse_qrcode_boarding_pass(barcode_data, df_airports, df_airlines)
    else:
        print("Unsupported barcode type.")
        return

    # Print the parsed information
    for key, value in boarding_pass_details.items():
        print(f"{key}: {value}")
    return None
    #return boarding_pass_details # JSON format

# Main function to handle command-line input

if __name__ == "__main__":
    # Set up command-line argument parsing
    parser = argparse.ArgumentParser(description="Scan a boarding pass barcode from an image (URL or file path).")
    parser.add_argument('image', nargs='?', default=None, help="Path to the image file or a URL to the boarding pass.")
    # Parse the arguments
    args = parser.parse_args()
    # Check if an argument was provided, else use default
    image_to_use = args.image
    if not image_to_use:
        # Default image path
        #image_to_use = "./Sample_Boarding_Passes/PDF417-Print-Long-BA.png" # PDF417
        image_to_use = "./Sample_Boarding_Passes/QRcode-Mobile-QR-AirParadise.png" # QRCode
        if not os.path.exists(image_to_use):
            print(f"Error: Input missing. Neither a command-line argument nor the default image file '{image_to_use}' were found.")
            exit(1)
    # Call the scan_boarding_pass function with the provided image (URL or path)
    result = scan_boarding_pass(image_to_use)
    if result:
        print(result)
