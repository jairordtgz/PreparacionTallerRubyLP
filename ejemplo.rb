class ExtractorOferta < ExtractorSteam

  # Sobrescribe el método de la clase padre
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
      # Solo juegos que tienen descuento
      next if item.at_css(".discount_pct").nil?
      nombre = limpiar_texto(
        item.at_css("span.title")&.text
      )
      enlace = item["href"] || ""
      precio_original = limpiar_texto(
        item.at_css(".discount_original_price")&.text
      )

      # Precio final
      precio_final = limpiar_texto(
        item.at_css(".discount_final_price")&.text
      )

      precio_original = "0" if precio_original == ""
      precio_final = "0" if precio_final == ""

      detalle = extraer_juego(enlace)

      juego = {
        nombre: nombre,
        enlace: enlace,
        fecha: detalle[:fecha],
        generos: detalle[:generos],
        precio_original: precio_original,
        precio_final: precio_final,
        desarrollador: detalle[:desarrollador]
      }

      @juegos << juego

      imprimir_juego(juego)

      contador += 1

    end

  end

  # Sobrescribe la exportación del CSV
  def exportar_csv(nombre_archivo)

    CSV.open(nombre_archivo, "w") do |csv|

      csv << [
        "Nombre",
        "Enlace",
        "Fecha",
        "Generos",
        "Precio Original",
        "Precio Final",
        "Desarrollador"
      ]

      @juegos.each do |juego|

        csv << [
          juego[:nombre],
          juego[:enlace],
          juego[:fecha],
          juego[:generos],
          juego[:precio_original],
          juego[:precio_final],
          juego[:desarrollador]
        ]

      end

    end

    puts "Archivo #{nombre_archivo} generado correctamente."

  end

end

def imprimir_juego(juego)

  puts "--------------------------------------"
  puts "Nombre           : #{juego[:nombre]}"
  puts "Enlace           : #{juego[:enlace]}"
  puts "Fecha            : #{juego[:fecha]}"
  puts "Generos          : #{juego[:generos]}"
  puts "Precio Original  : #{juego[:precio_original]}"
  puts "Precio Final     : #{juego[:precio_final]}"
  puts "Desarrollador    : #{juego[:desarrollador]}"
  puts "--------------------------------------"

end