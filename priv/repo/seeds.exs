# Script for populating the database.

location_a = %{latitude: 47, longitude: 10}
location_b = %{latitude: 47, longitude: 11}
PeakTracker.Mountains.Services.Peaks.Import.execute(location_a, location_b)
