require 'nokogiri'
require 'open-uri'
require 'csv'

url = "https://store.steampowered.com/app/730/CounterStrike_2/"

begin
  # Descarga y parsea el HTML de la URL
  doc = Nokogiri::HTML(URI.open(url).read)

  # Guarda el contenido en un archivo llamado 'steam_page.html'
  File.open("steam_page.html", "w") do |file|
    file.write(doc.to_html)
  end

  puts "¡No hubo problemas! El archivo HTML se guardó correctamente."
rescue => e
  puts "Ocurrió un error durante el scraping: #{e.message}"
end
