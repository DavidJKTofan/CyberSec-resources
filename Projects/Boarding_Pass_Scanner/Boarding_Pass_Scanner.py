import os
import zxing # Dependency on Java OpenJDKv11 # brew install openjdk@11
import re
import pandas as pd
import requests

# Define function to clean and load the DAT files
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

# Function to scan boarding pass and extract information
def scan_boarding_pass(image_here):
    # Creating a BarcodeReader object
    reader = zxing.BarCodeReader()

    # If the input is a URL, download the image
    if isinstance(image_here, str) and image_here.startswith("https://"):
        image_path = 'bar_image.png'
        with open(image_path, 'wb') as handle:
            response = requests.get(image_here, stream=True)
            if response.ok:
                for block in response.iter_content(1024):
                    if not block:
                        break
                    handle.write(block)
        image_here = os.path.join(os.getcwd(), image_path)
    
    # Decoding the image
    mytext = reader.decode(image_here)

    if not mytext:
        print("Error decoding the barcode.")
        return

    BarCode_Format = mytext.format
    BarCode_Raw = mytext.raw.upper()

    print("Raw Barcode Value: ", BarCode_Raw)

    if BarCode_Format not in ['PDF_417', 'AZTEC']:
        print("Wrong bar code format!")
        return

    # Load reference data
    df_airports, df_airlines = load_and_clean_dat_files()

    # Split the barcode data into fields
    fields = BarCode_Raw.split()
    
    # Extract Passenger Name
    try:
        if "/" in fields[0]:
            name_parts = fields[0].split("/")
            Passenger_Name_LastName = name_parts[0].strip("M1")
            Passenger_Name_FirstName = name_parts[1]
            Passenger_Name = f"{Passenger_Name_FirstName} {Passenger_Name_LastName}"
        else:
            Passenger_Name = "NONE"
    except:
        Passenger_Name = "NONE"
        print("The passenger name could not be located.\n")

    # Extract Reservation Number (Field 7)
    try:
        for field in fields:
            if len(field) == 7 and field.isalnum():
                Reservation_Number = field[1:] # removes "E": Electronic Ticket Indicator
                break
        else:
            Reservation_Number = "UNKNOWN"
    except:
        Reservation_Number = "UNKNOWN"
        print("The Reservation Number could not be located.\n")

    # Extract Airport Codes
    try:
        for field in fields:
            if len(field) >= 6 and field.isalpha():
                Flight_Airport_Departure = field[:3]
                Flight_Airport_Destination = field[3:6]
                break
        else:
            Flight_Airport_Departure = "UNKNOWN"
            Flight_Airport_Destination = "UNKNOWN"
    except:
        Flight_Airport_Departure = "UNKNOWN"
        Flight_Airport_Destination = "UNKNOWN"

    # Extract Airline Code and Flight Number
    try:
        # Find the airline code and flight number pattern
        airline_pattern = re.compile(r'([A-Z]{2,3})(\d{3,4})')
        for field in fields:
            match = airline_pattern.search(field)
            if match:
                Flight_Airline = match.group(1)
                Flight_Number = match.group(2)
                break
        else:
            Flight_Airline = "UNKNOWN"
            Flight_Number = "UNKNOWN"
    except:
        Flight_Airline = "UNKNOWN"
        Flight_Number = "UNKNOWN"

    # Extract Seat Number from format like "330M028F0071" - looking for the pattern "dddMdddL" where d=digit, L=letter
    try:
        seat_pattern = re.compile(r'\d{3}M(\d{3})([A-Z])')
        for field in fields:
            match = seat_pattern.search(field)
            if match:
                row = str(int(match.group(1)))  # Remove leading zeros
                letter = match.group(2)
                Seat_Number = f"{row}{letter}"
                break
        else:
            Seat_Number = "UNKNOWN"
    except:
        Seat_Number = "UNKNOWN"
        print("The Seat Number could not be located.\n")

    # Look up airport names
    try:
        departure_airport = df_airports.loc[df_airports['IATA'] == Flight_Airport_Departure]
        Flight_Airport_Departure_Name = departure_airport['Name'].values[0] if not departure_airport.empty else "UNKNOWN"
        
        destination_airport = df_airports.loc[df_airports['IATA'] == Flight_Airport_Destination]
        Flight_Airport_Destination_Name = destination_airport['Name'].values[0] if not destination_airport.empty else "UNKNOWN"
    except Exception as e:
        print(f"Error fetching airport details: {e}")
        Flight_Airport_Departure_Name = "UNKNOWN"
        Flight_Airport_Destination_Name = "UNKNOWN"

    # Look up airline name from airlines.dat
    try:
        airline = df_airlines.loc[df_airlines['IATA'] == Flight_Airline]
        Flight_Airline_Name = airline['Airline'].values[0] if not airline.empty else "UNKNOWN"
    except Exception as e:
        print(f"Error fetching airline details: {e}")
        Flight_Airline_Name = "UNKNOWN"

    # Print extracted information
    print(f"Passenger Name: {Passenger_Name}")
    print(f"Reservation Number: {Reservation_Number}")
    print(f"Departure Airport: {Flight_Airport_Departure_Name} ({Flight_Airport_Departure})")
    print(f"Destination Airport: {Flight_Airport_Destination_Name} ({Flight_Airport_Destination})")
    print(f"Airline: {Flight_Airline_Name} ({Flight_Airline})")
    print(f"Flight Number: {Flight_Number}")
    print(f"Seat: {Seat_Number}")
    print(f"Raw Barcode Value: {BarCode_Raw}")

    return {
        'passenger_name': Passenger_Name,
        'reservation_number': Reservation_Number,
        'departure_airport': Flight_Airport_Departure,
        'departure_airport_name': Flight_Airport_Departure_Name,
        'destination_airport': Flight_Airport_Destination,
        'destination_airport_name': Flight_Airport_Destination_Name,
        'airline': Flight_Airline,
        'airline_name': Flight_Airline_Name,
        'flight_number': Flight_Number,
        'seat_number': Seat_Number,
        'raw_barcode': BarCode_Raw
    }

# Example usage
if __name__ == "__main__":
    image_url = "test.png"
    scan_boarding_pass(image_url)