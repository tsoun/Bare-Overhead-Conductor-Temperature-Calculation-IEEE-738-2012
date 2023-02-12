import tkinter as tk
from tkinter import messagebox
import requests
import json
import csv

# Function to convert JSON data to CSV
def JSONtoCSV(data, csvFile):
    with open(csvFile, 'w') as f:
        writer = csv.writer(f)
        writer.writerow(key for key in data)

        dataMatrix = []
        for key in data.keys():
            dataMatrix.append(data[key])
        trDataMatrix = (list(zip(*dataMatrix)))
        for item in trDataMatrix:
            writer.writerow(item)

# Function to make API request and save data in CSV
def get_forecast():
    # API endpoint for Open-meteo API
    api_url = 'https://api.open-meteo.com/v1/forecast'

    # Get coordinates from GUI
    latitude = lat_entry.get()
    longitude = lon_entry.get()

    # Check for valid input
    if not latitude or not longitude:
        messagebox.showerror("Error", "Please enter valid coordinates.")
        return

    # API request
    response = requests.get(f"{api_url}?latitude={latitude}&longitude={longitude}&hourly=temperature_2m,relativehumidity_2m,pressure_msl,windspeed_10m,winddirection_10m&timezone=auto")

    # Save API response
    with open('api_response.json', 'w') as f:
        json.dump(response.json(), f)

    # Extract forecast data from API response
    data = response.json()['hourly']

    # Save forecast data in CSV file
    csvFile = 'weather_forecast.csv'
    JSONtoCSV(data, csvFile)
    messagebox.showinfo("Επιτυχία!", "Η πρόβλεψη αποθηκεύτηκε στο " + csvFile +".")

# Create GUI
root = tk.Tk()
root.geometry("450x300")
root.title("Αναφορά Μετεωρολογικής Πρόβλεψης | Πανεπιστήμιο Πατρών")

# Configure rows and columns to expand with the window
for i in range(4):
    root.grid_rowconfigure(i, weight=1)
root.grid_columnconfigure(1, weight=1)

# Create labels and entry widgets for latitude and longitude
lat_label = tk.Label(root, text="Γεωγραφικό πλάτος:")
lat_label.grid(row=0, column=0, sticky="W", padx=(50), pady=50)
lat_entry = tk.Entry(root)
lat_entry.grid(row=0, column=1, sticky="EW", padx=(10, 50))
lon_label = tk.Label

lon_label = tk.Label(root, text="Γεωγραφικό μήκος:")
lon_label.grid(row=1, column=0, sticky="W", padx=(50))
lon_entry = tk.Entry(root, width = 200)
lon_entry.grid(row=1, column=1, sticky="EW", padx=(10, 50))

# Create a button to make API request
get_forecast_button = tk.Button(root, text="Λήψη Πρόβλεψης", command=get_forecast)
get_forecast_button.grid(row=2, column=0, columnspan=2, pady=50, padx = 50, sticky="EW")

# Create a footer label
footer_label = tk.Label(root, text="2023 (C) Πανεπιστήμιο Πατρών", font=("Helvetica", 8))
footer_label.grid(row=3, column=0, columnspan=2, pady=2.5, sticky="W")

root.mainloop()
