# imprime mensaje de bienvenida en consola
puts 'Practicando Ruby'
# importa librerias
require 'open-uri'
require 'nokogiri'
require 'csv'

#define la clase Extractor
class Extractor
    # crea metodos getter y setter para las variables archivo y url
  attr_accessor :archivo, :url
    # constructor de la clase
  def initialize(archivo)
    # guarda el nombre del archivo csv en una variable de instancia
    @archivo = archivo
  end

  # metodo para limpiar el contenido del archivo csv
  def limpiar(archivo)
    # abre el archivo en modo escritura y borra su contenido
    CSV.open(archivo, 'w') do |csv|
    end
  end 
# metodo para guardar una fila de datos en el archivo csv
  def guardar(archivo, datos)
    # abre el archivo en modo agregar
    CSV.open(archivo, 'a') do |csv|
    # inserta la fila con los datos recibidos
    csv << datos
    end
  end

  # metodo para scrapear los datos de la pagina confiesalo
   def obtenerDatos(url, palabraClave)
    # imprime la url que se esta procesando
    puts "Scrapeando #{url}..."
    # abre la pagina web de la url
    confiesaloHTML = URI.open(url)
    # lee el contenido de la pagina
    datos = confiesaloHTML.read
    #convierte el html en un formato procesable para nokogiri
    parsed_content = Nokogiri::HTML(datos)
    # busca el contenedor principal donde estan las confesiones
    datosContenedor = parsed_content.css('.infinite-container')
    #recorre cada confesion encontrada
    datosContenedor.css('.infinite-item').each do |confesiones|
        # obtiene el encabezado de la confesion
      header = confesiones.css('div div.row').css('.meta__container--without-image').css('.row')
        # obtiene la seccion donde estan los likes y dislikes
      masInfo = confesiones.css('div.row').css('.read-more')
        # extrae el identificador del autor
      id_author = header.css('.meta__info').css('.meta__author').css('a').css('a:nth-child(3)').inner_text[1..-1]
        # extrae nombre del autor
      author = header.css('.meta__info').css('.meta__author').at_css('a').inner_text[0..6]
        # extrae la fecha y la separa
      date = header.css('.meta__info').css('.meta__date').inner_text.strip.split(' ')
        # comprueba si la fecha contiene toda la informacion esperada
      unless date[5].nil?
        # contruye la cadena de la fecha
        strFecha = date[1] + ' ' + date[2] + ' ' + date[3][0..3]
        # contruye la cadena con la hora
        strHour = date[4] + ' ' + date[5]
        # caso contrario la fecha y la hora quedan vacias
      else
        strFecha = nil
        strHour = nil
        end
        # obtiene el texto de la confesión, numero de likes y dislikes
      content = confesiones.css('div.row').css('.post-content-text').inner_text.gsub("\n", '')
      nrolikes = masInfo.css('span').css("#votosup-#{id_author}").inner_text
      nrodislikes = masInfo.css('span').css("#votosdown-#{id_author}").inner_text
        # genera un numero aleatorio de comentarios del 1 al 100
      nroComentarios = rand(1..100)
      # comprueba si el texto de la confesion incluye la palabra clave
      if content.include? palabraClave
        # guarda los datos encontrados en el csv
        guardar(archivo, [palabraClave, author.to_s, strFecha.to_s, strHour.to_s, nrolikes.to_i, nrodislikes.to_i, nroComentarios.to_i ,content.to_s])
      end
    end
    # imprime cada vez que termina de analizar una pagina 
     print "confesiones.csv actualizado \n"
   end
   #fin de la clase Extractor
end

# mensaje de bienvenida
puts "Bienvenido al sistema para extraer confesiones"
# solicita el numero de paginas
print "Ingrese nro páginas: "
# lee el numero ingresado y lo convierte en entero
paginaFinal = gets().to_i
# inicializar contador 
cont=1
# crea objeto extractor indicando el nombre del archivo
extractor = Extractor.new("confesiones.csv")
# limpia el contenido del archivo
extractor.limpiar(extractor.archivo)
# escribe la fila de encabezados en el csv
extractor.guardar(extractor.archivo, %w[Clave Autor Fecha Hora nrolikes nrodislikes nroComentarios texto])
# repite el proceso mientras el contador sea menor o igual a 3
until cont>3
  # solicita la palabra clave a buscar 
  print "Ingrese palabra clave a buscar:"
  # lee la palabra clave eliminando espacios
  palabraClave = gets().strip
  # inicia en la pagina 1
  paginaActual = 1
  # inicia en la linea 1
  nroLinea = 1
  # bucle para recorrer todas las paginas indicadas por el usuario
  while (paginaActual<=paginaFinal)
      # variable de la url actual
      link = "https://confiesalo.net/?page=#{paginaActual}"
      # obtiene los datos de la pagina
      linea = extractor.obtenerDatos(link, palabraClave)
      # incrementa la pagina actual
      paginaActual+=1
  end
  cont+=1
end

# mensaje final
puts "Nota: No comparta las confesiones... XD"



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

2. Solo en ExtractorOferta agrega este método
def imprimir_juego(juego)

  puts "--------------------------------------"
  puts "Nombre            : #{juego[:nombre]}"
  puts "Enlace            : #{juego[:enlace]}"
  puts "Fecha             : #{juego[:fecha]}"
  puts "Generos           : #{juego[:generos]}"
  puts "Precio Original   : #{juego[:precio_original]}"
  puts "Precio Final      : #{juego[:precio_final]}"
  puts "Desarrollador     : #{juego[:desarrollador]}"
  puts "--------------------------------------"

end