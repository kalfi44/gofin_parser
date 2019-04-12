require 'nokogiri'
require 'httparty'
require 'byebug'
require 'open-uri'

# @todo link file explaining scraping logic
# This method is used to scrap ordinance from gofin-web page
# Logic behind this method (like fixed values 2 and 4) 
# is discribed in more details in linked file.
# @return Array[<Nokogiri::XML::Element>] data it returns 8-element array of Nokogiri::XML::Element which responds for holding information about each attachment of ordinance
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
  return data
end

# This method is used to split string after first space
# and then return content before and after said space
# @param [String] string to be split
# @return [Array<String>] Two element array containig string before first space and string after it 
def split_and_assemble(str)
  arr = str.split(' ')
  chapter_name = " "
  for i in 1...arr.size
    chapter_name << (arr[i] + " ")
  end
  return arr[0], chapter_name.strip!
end

# This method is used to parse content of attachment nr. 2
# It distincts pragraphs describing sections and chapters by 
# diffrent html elements (<p> and <b> or <strong>)
# @param [Nokogiri::XML::Element] Nokogiri element with content of attachment 2
# @return [Array<Hash<String, String>>] It returns an array of 2 hash tables. These hash table key is code and value is name. First Hash holds codes of sections and second about chapters. 
def att_2_parse(data)
  sec = []
  chap =[]

  data.css('b').each do |x|
      sec.push(x)
  end

  data.css('strong').each do |x|
    sec.push(x)
  end
  
  data.css('p').each do |x|
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
  return sections, chapters
end

# This method is used to parse content of attachment nr. 3 or nr. 4
# It can be used on both of the attachments as they have simillar structure.
# @param [Nokogiri::XML::Element] Nokogiri element with content of attachment 3 or attachment 4
# @return [Array<Hash<String, String>>] It returns an array of 2 hash tables. These hash table key is code and value is name. First Hash holds codes of paragraphs and second about meaning of last digit in paragraph code. 
def att_3_4_parse(data)
  paragraphs = {}
  last_digit_code = {}
  data.css('p').each do |x|
    if (matched_string = x.text.match(/^[\d]\s+(\S*(\s|\p{Zs})*)+/)) != nil
      key,val = split_and_assemble(matched_string.to_s)
      last_digit_code[key]=val
    elsif (matched_string = x.text.match(/^[\d]\d{2}\s+(\S*(\s|\p{Zs})*)+/)) != nil
      key,val = split_and_assemble(matched_string.to_s)
      paragraphs[key]=val
    end
  end
  return paragraphs, last_digit_code
end

# This method is used to parse content of attachment nr. 5 or nr. 6
# It can be used on both of the attachments as they have simillar structure.
# @param [Nokogiri::XML::Element] Nokogiri element with content of attachment 5 or attachment 6
# @return [Array<Hash<String, String>>] It returns hash table of codes and names described in attachment 5 or 6. These hash table key is code and value is name.  
def att_5_6_parse(data)
  paragraphs = {}
  data.css('p').each do |x|
    matched_string = x.text.match(/^[\d]\d{2}\s+(\S*(\s|\p{Zs})*)+/)
    if matched_string != nil
      key,val = split_and_assemble(matched_string.to_s)
      paragraphs[key]=val
    end     
  end
  return paragraphs
end

# @todo Consult meaning of data returned by this function and apply possible changes
# Usage of this function is not advised as codes desrcibed in attachment 7 and 8 need to be further understood 
# This method is used to parse content of attachment nr. 7 or nr. 8
# It can be used on both of the attachments as they have simillar structure.
# @param [Nokogiri::XML::Element] Nokogiri element with content of attachment 7 or attachment 8
# @return [Array<Hash<String, String>>] It returns an array of 2 hash tables. These hash table key is code and value is name. First Hash holds codes of sections and second about codes of pargraphs from attachment 7 or 8. 
def att_7_8_parse(data)
  att_p = []
  att_sb = []

  att_sec = {}
  att_par = {}
 
  data.css('p').each do |x|
    att_p.push(x)
  end
  
  data.css('b').each do |x|
    att_sb.push(x)
  end
  
  data.css('strong').each do |x|
    att_sb.push(x)
  end

  att_sb.each do |x|
    matched_string = x.text.match(/^[\d]\d{2}\s+(\p{L}*(\s|\p{Zs})*)+/) 
    if matched_string !=nil
      key,val = split_and_assemble(matched_string.to_s)
      att_sec[key]=val
    end
  end

  att_p.each do |x|
    matched_string = x.text.match(/^[\d]\d{5}\s+(\S*(\s|\p{Zs})*)+/)
    if matched_string != nil
      key,val = split_and_assemble(matched_string.to_s)
      att_par[key]=val
    end     
  end
  return att_sec, att_par
end



