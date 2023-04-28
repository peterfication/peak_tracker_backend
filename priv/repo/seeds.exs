# Script for populating the database.

{:ok, peaks} = PeakTracker.Mountains.Peak.list()

if Enum.empty?(peaks.results) do
  # This just imports some peaks into the database. In order to import all peaks
  # of the whole world, PeakTracker.Mountains.Services.Peaks.ImportWorld.execute()
  # has to be used, but this will take a long time to succeed because of the amount
  # of data.
  PeakTracker.Mountains.Services.Peaks.Import.execute({
    %Location{latitude: 47, longitude: 10},
    %Location{latitude: 47, longitude: 11}
  })
else
  IO.puts("Peaks already populated")
end
