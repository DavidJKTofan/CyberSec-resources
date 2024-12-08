# Simple Boarding Pass Scanner

A simple tool to scan and decode boarding pass barcodes, supporting `QRCode` and `PDF417` formats.

**Supported Barcode Formats:**
- **PDF417**: Typically found on paper boarding passes, these are long barcodes.
- **QRCode**: Square barcodes, often used in digital boarding passes, such as those in phone wallets.

**Note:** The scanner works best with cropped, high-quality images of the barcodes.

## Boarding Pass Structure

![Boarding Pass Structure](/Projects/Boarding_Pass_Scanner/boarding-pass-structure.jpg)

Source: [Page 27, 4.2.2. Encoding one flight leg](https://tinkrmind.me/wp-content/uploads/2017/09/bcbp-implementation-guide-5th-edition-june-2016.pdf)

### Key Elements in the Boarding Pass

| Item # | Element Description                                         | Field Size | Type  | Example                          |
|--------|-------------------------------------------------------------|------------|-------|----------------------------------|
| 1      | Format Code                                                 | 1          | Unique | M                                |
| 5      | Number of Legs Encoded                                      | 1          | Unique | 1                                |
| 11     | Passenger Name                                              | 20         | Unique | D.ESMARIS / LUCAS                |
| 253    | Electronic Ticket Indicator                                 | 1          | Unique | E                                |
| 7      | Operating Carrier PNR Code                                  | 7          | Repeated | ABC123                           |
| 26     | From City Airport Code                                      | 3          | Repeated | YUL                              |
| 38     | To City Airport Code                                        | 3          | Repeated | FRA                              |
| 42     | Operating Carrier Designator                                | 3          | Repeated | AC                               |
| 43     | Flight Number                                               | 5          | Repeated | 08345                            |
| 46     | Date of Flight (Julian Date)                                | 3          | Repeated | 226 (August 14th)                |
| 71     | Compartment Code                                            | 1          | Repeated | F                                |
| 104    | Seat Number                                                 | 4          | Repeated | 001A                             |
| 107    | Check-in Sequence Number                                    | 5          | Repeated | 0025                             |
| 113    | Passenger Status                                            | 1          | Repeated | 1                                |
| 6      | Field Size of Variable Size Field (Conditional + Airline item 4) | 2          | Repeated | 00 (in Decimal or Hexadecimal)   |

---

## How to Run

Create a virtual environment (`source venv/bin/activate`) and install all required packages.

You can run the boarding pass scanner from your terminal:

```
python3 Boarding_Pass_Scanner.py <image_url_or_file_path>
```

### Example Usage:
```
python3 Boarding_Pass_Scanner.py "./Sample_Boarding_Passes/Print-Long-BA.png"
```

---

## Disclaimer

This project is a small personal experiment created out of curiosity. It may not handle all edge cases and is primarily intended for educational purposes.
