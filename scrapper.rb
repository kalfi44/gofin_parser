require 'nokogiri'
require 'httparty'
require 'byebug'
require 'open-uri'

def split_and_assemble(str)
  arr = str.split(' ')
  chapter_name = " "
  for i in 1...arr.size
    chapter_name << (arr[i] + " ")
  end
  return arr[0], chapter_name.strip!
end

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

  #Attachment 1&2 parse
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
    matched_string = x.text.match(/^[\d]\d{4}\s+(\S*(\s|\p{Zs})*)+/)
    if matched_string != nil
      key,val = split_and_assemble(matched_string.to_s)
      chapters[key]=val
    end     
  end
  #Attachment 3 parse

  par = []
  paragraphs_i = {}
  incomes = {}
  expenses = {}
  paragraphs_e = {}
  

  data[2].css('p').each do |x|
    par.push(x)
  end

  par.each do |x|
    if (matched_string = x.text.match(/^[\d]\s+(\S*(\s|\p{Zs})*)+/)) != nil
      puts matched_string
      key,val = split_and_assemble(matched_string.to_s)
      incomes[key]=val
    elsif (matched_string = x.text.match(/^[\d]\d{2}\s+(\S*(\s|\p{Zs})*)+/)) != nil
      #puts matched_string
      key,val = split_and_assemble(matched_string.to_s)
      paragraphs_i[key]=val
    end
  end
  
  #Attachment 4 withou groups for now
  data[3].css('p').each do |x|
    if (matched_string = x.text.match(/^[\d]\s+(\S*(\s|\p{Zs})*)+/)) != nil
      puts matched_string
      key,val = split_and_assemble(matched_string.to_s)
      expenses[key]=val
    elsif (matched_string = x.text.match(/^[\d]\d{2}\s+(\S*(\s|\p{Zs})*)+/)) != nil
      #puts matched_string
      key,val = split_and_assemble(matched_string.to_s)
      paragraphs_e[key]=val
    end
    
  end
   
  byebug
end

scrapper
