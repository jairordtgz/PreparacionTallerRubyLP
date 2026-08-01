puts 'Practicando Ruby'
require 'open-uri'
require 'nokogiri'
require 'csv'

class Extractor
  attr_accessor :archivo, :url

  def initialize(archivo)
    @archivo = archivo
  end

  def limpiar(archivo)
    CSV.open(archivo, 'w') do |csv|
    end
  end 

  def guardar(archivo, datos)
    CSV.open(archivo, 'a') do |csv|
    csv << datos
    end
  end

   def obtenerDatos(url, palabraClave)
    puts "Scrapeando #{url}..."
    confiesaloHTML = URI.open(url)
    datos = confiesaloHTML.read
    parsed_content = Nokogiri::HTML(datos)
    datosContenedor = parsed_content.css('.infinite-container')
    datosContenedor.css('.infinite-item').each do |confesiones|
      header = confesiones.css('div div.row').css('.meta__container--without-image').css('.row')

      masInfo = confesiones.css('div.row').css('.read-more')
      id_author = header.css('.meta__info').css('.meta__author').css('a').css('a:nth-child(3)').inner_text[1..-1]

      author = header.css('.meta__info').css('.meta__author').at_css('a').inner_text[0..6]

      date = header.css('.meta__info').css('.meta__date').inner_text.strip.split(' ')

      unless date[5].nil?
        strFecha = date[1] + ' ' + date[2] + ' ' + date[3][0..3]
        strHour = date[4] + ' ' + date[5]
      else
        strFecha = nil
        strHour = nil
        end
      content = confesiones.css('div.row').css('.post-content-text').inner_text.gsub("\n", '')
      nrolikes = masInfo.css('span').css("#votosup-#{id_author}").inner_text
      nrodislikes = masInfo.css('span').css("#votosdown-#{id_author}").inner_text
      nroComentarios = rand(1..100)
      if content.include? palabraClave
        guardar(archivo, [palabraClave, author.to_s, strFecha.to_s, strHour.to_s, nrolikes.to_i, nrodislikes.to_i, nroComentarios.to_i ,content.to_s])
      end
    end
     print "confesiones.csv actualizado \n"
   end
end

puts "Bienvenido al sistema para extraer confesiones"
print "Ingrese nro páginas: "
paginaFinal = gets().to_i
cont=1
extractor = Extractor.new("confesiones.csv")
extractor.limpiar(extractor.archivo)
extractor.guardar(extractor.archivo, %w[Clave Autor Fecha Hora nrolikes nrodislikes nroComentarios texto])
until cont>3
  print "Ingrese palabra clave a buscar:"
  palabraClave = gets().strip
  paginaActual = 1
  nroLinea = 1
  while (paginaActual<=paginaFinal)
      link = "https://confiesalo.net/?page=#{paginaActual}"
      linea = extractor.obtenerDatos(link, palabraClave)
      paginaActual+=1
  end
  cont+=1
end
puts "Nota: No comparta las confesiones... XD"



