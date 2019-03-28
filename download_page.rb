require 'open-uri'
url = 'http://www.przepisy.gofin.pl/przepisy,4,16,194,1276,131381,20190101,rozporzadzenie-ministra-finansow-z-dnia-2032010-r-w-sprawie.html'
fh = open(url)

html = fh.read 

puts html
