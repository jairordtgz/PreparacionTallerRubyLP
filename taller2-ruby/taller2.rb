require "nokogiri"
require "open-uri"
require "csv"

class ExtractorSteam
  attr_accessor :url, :tipo, :categoria, :limite, :juegos, :headers
  def initialize(url, tipo, categoria, limite)
    @url = url
    @tipo = tipo
    @categoria = categoria
    @limite = limite
    @juegos = []
    @headers = ["Nombre","Enlace","Fecha","Generos","Precio","Desarrollador"]
  end

  def obtener_pagina(url_general)
    puts "Consultando:"
    puts url_general
    html = URI.open(url_general).read
    Nokogiri::HTML(html)
  end

  def limpiar_texto(texto)
    return "" if texto.nil?
    texto.gsub("\n"," ")
         .gsub("\t"," ")
         .strip
         .gsub(/\s+/," ")
  end

  def extraer_juego(url_juego)
    begin
      puts "Entrando a:"
      puts url_juego

      html = URI.open(url_juego).read
      pagina = Nokogiri::HTML(html)
      fecha = ""

      nodo_fecha = pagina.at_css(".release_date .date")

      unless nodo_fecha.nil?
        fecha = limpiar_texto(nodo_fecha.text)
      end

      generos = ""

      pagina.css("#genresAndManufacturer a").each do |item|
        href = item["href"]
        next if href.nil?
        if href.include?("genre")
          if generos == ""
            generos = limpiar_texto(item.text)
          else
            generos += ", " + limpiar_texto(item.text)
          end
        end
      end

      desarrollador = ""
      pagina.css("#developers_list a").each do |dev|
        if desarrollador == ""
          desarrollador = limpiar_texto(dev.text)
        else
          desarrollador += ", " + limpiar_texto(dev.text)
        end
      end

      return {
        fecha: fecha,
        generos: generos,
        desarrollador: desarrollador
      }

    rescue

      return {
        fecha: "",
        generos: "",
        desarrollador: ""
      }
    end
  end

  def exportar_csv(nombre_archivo)
    CSV.open(nombre_archivo, "w") do |csv|
      csv << @headers
      @juegos.each do |juego|
        csv << [
          juego[:nombre],
          juego[:enlace],
          juego[:fecha],
          juego[:generos],
          juego[:precio],
          juego[:desarrollador]
        ]
      end
    end
    puts "Archivo #{nombre_archivo} generado correctamente."
  end

  def imprimir_juego(juego)

    puts "--------------------------------------"
    puts "Nombre        : #{juego[:nombre]}"
    puts "Enlace        : #{juego[:enlace]}"
    puts "Fecha         : #{juego[:fecha]}"
    puts "Generos       : #{juego[:generos]}"
    puts "Precio        : #{juego[:precio]}"
    puts "Desarrollador : #{juego[:desarrollador]}"
    puts "--------------------------------------"

  end

end

class ExtractorGeneral < ExtractorSteam

  def obtener_juegos
    pagina = obtener_pagina(@url)
    lista = pagina.css("a.search_result_row")
    contador = 0

    lista.each do |item|
      break if contador >= @limite
      nombre = limpiar_texto(
        item.at_css("span.title")&.text
      )

      enlace = item["href"] || ""
      precio = ""
      precio_normal = item.at_css(".discount_final_price")

      if precio_normal.nil?
        gratis = item.at_css(".search_price")
        unless gratis.nil?
          precio = limpiar_texto(gratis.text)
        end

      else
        precio = limpiar_texto(precio_normal.text)
      end

      precio = "0" if precio == ""
      detalle = extraer_juego(enlace)
      juego = {
        nombre: nombre == "" ? "" : nombre,
        enlace: enlace,
        fecha: detalle[:fecha] == "" ? "" : detalle[:fecha],
        generos: detalle[:generos] == "" ? "" : detalle[:generos],
        precio: precio,
        desarrollador: detalle[:desarrollador] == "" ? "" : detalle[:desarrollador]
      }
      @juegos << juego
      imprimir_juego(juego)
      contador += 1
    end
  end
end

class ExtractorOferta < ExtractorSteam

  def obtener_pagina(url_general)
    puts "Consultando juegos en oferta..."
    super(url_general + "?specials=1")
  end

  def obtener_juegos
    pagina = obtener_pagina(@url)
    lista = pagina.css("a.search_result_row")
    contador = 0

    lista.each do |item|
      break if contador >= @limite
      next if item.at_css(".discount_pct").nil?
      nombre = limpiar_texto(
        item.at_css("span.title")&.text
      )

      enlace = item["href"] || ""

      precio = limpiar_texto(
        item.at_css(".discount_final_price")&.text
      )

      precio = "0" if precio == ""
      detalle = extraer_juego(enlace)
      juego = {
        nombre: nombre,
        enlace: enlace,
        fecha: detalle[:fecha],
        generos: detalle[:generos],
        precio: precio,
        desarrollador: detalle[:desarrollador]
      }
      @juegos << juego
      imprimir_juego(juego)
      contador += 1
    end
  end
end

class ExtractorGratuitos < ExtractorSteam

  def obtener_pagina(url_general)
    puts "Consultando juegos gratuitos..."
    super(url_general + "?maxprice=free")
  end

  def obtener_juegos
    pagina = obtener_pagina(@url)
    lista = pagina.css("a.search_result_row")
    contador = 0

    lista.each do |item|
      break if contador >= @limite

      texto_precio = limpiar_texto(
        item.css(".search_price").text
      ).downcase

      next unless texto_precio.include?("free") ||
                  texto_precio.include?("play")

      nombre = limpiar_texto(
        item.at_css("span.title")&.text
      )

      enlace = item["href"] || ""
      detalle = extraer_juego(enlace)

      juego = {
        nombre: nombre,
        enlace: enlace,
        fecha: detalle[:fecha],
        generos: detalle[:generos],
        precio: "0",
        desarrollador: detalle[:desarrollador]
      }

      @juegos << juego
      imprimir_juego(juego)
      contador += 1

    end
  end
end


puts " EXTRACTOR DE VIDEOJUEGOS DE STEAM"

url_base = "https://store.steampowered.com/search/"

# Número de juegos a extraer de cada categoría
limite = 20

puts
puts "Extrayendo juegos generales..."

general = ExtractorGeneral.new(
  url_base,
  "General",
  "",
  limite
)

general.obtener_juegos
general.exportar_csv("juegos_generales.csv")

puts
puts "Extrayendo juegos en oferta..."

ofertas = ExtractorOferta.new(
  url_base,
  "Oferta",
  "",
  limite
)

ofertas.obtener_juegos
ofertas.exportar_csv("juegos_oferta.csv")

puts
puts "Extrayendo juegos gratuitos..."

gratuitos = ExtractorGratuitos.new(
  url_base,
  "Gratuitos",
  "",
  limite
)

gratuitos.obtener_juegos
gratuitos.exportar_csv("juegos_gratuitos.csv")

puts
puts "======================================"
puts "Proceso finalizado correctamente."
puts "Archivos generados:"
puts "- juegos_generales.csv"
puts "- juegos_oferta.csv"
puts "- juegos_gratuitos.csv"