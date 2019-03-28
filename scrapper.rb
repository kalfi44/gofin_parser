require 'nokogiri'
require 'httparty'
require 'byebug'
require 'open-uri'

def scrapper
  url = 'http://www.przepisy.gofin.pl/przepisy,4,16,194,1276,131381,20190101,rozporzadzenie-ministra-finansow-z-dnia-2032010-r-w-sprawie.html'
 # html = fh.read()
  #taht seems to be not needed
  unparsed_page = HTTParty.get(url)
  #res = html.encode("utf-8").split("Załącznik")
  #puts res[1]
  parsed_page = Nokogiri::HTML(unparsed_page)
  byebug
end

scrapper
