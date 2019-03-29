require 'nokogiri'
require 'httparty'
require 'byebug'
require 'open-uri'

def scrapper
  url = 'http://www.przepisy.gofin.pl/przepisy,4,16,194,1276,131381,20190101,rozporzadzenie-ministra-finansow-z-dnia-2032010-r-w-sprawie.html'
  
  unparsed_page = HTTParty.get(url)
  parsed_page = Nokogiri::HTML(unparsed_page)
 
  scrapped_data = []

  parsed_page.css('div').each do |x|
      if (x.text.match(/Załącznik nr \d/)) != nil
        scrapped_data.push(x)
      end
  end

  data = []

  i = 0
  sum = 0

  scrapped_data.each do |x| 
    sum += x.css('div.PolozenieTresciRight_NazwaSymbol').count
    i+=1

    if sum==2
      data.push(x)
    end 

    if i == 4
    sum=i=0
    end

  end

  sec = []
  chap =[]

  data[1].css('b').each do |x|
      sec.push(x)
  end

  data[1].css('strong').each do |x|
    sec.push(x)
  end
  
  data[1].css('p').each do |x|
    chap.push(x)
  end 
 
  sections = {}
  chapters = {}

  sec.each do |x|
    matched_string = x.text.match(/\d{3}\s*-\s*(\p{L}*(\s|\p{Zs})*)+/) 
    if matched_string !=nil
      arr = matched_string.to_s.split('-')
      sections[arr[0].strip!] = arr[1].strip!
    end
  end

  chap.each do |x|
    matched_string = x.text.match(/\d{5}\s+(\S*(\s|\p{Zs})*)+/)
    if matched_string != nil
      arr = matched_string.to_s.split(' ')
      chapter_name = " "
      for i in 1...arr.size
        chapter_name << (arr[i] + " ")
      end
      chapters[arr[0]]=chapter_name
    end     
  end

  #byebug
end

#scrapper
