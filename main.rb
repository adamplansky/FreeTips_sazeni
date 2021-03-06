require 'rubygems'
require 'mechanize'
require 'open-uri'
require 'logger'

def arrPrint(arr)
  arr.each_index do |i|
    if i%7 == 0
      print "#{arr[i]}: "
    elsif i%7 == 2
      puts arr[i]
    end
  end
end


def win(arr)
  sum = 0.0
  arr.each_index do |i|
     if i%7 == 2
       sum += arr[i].to_f
     end
   end
   sum
end

#init
arrOK = Array.new 
arrNotOK = Array.new 
a = Mechanize.new

a.get('http://www.vojtovosazeni.cz/prihlaseni') do |page|

  #login
  my_page = page.form_with(:id => 'frm-signInForm') do |form|
    form.username  = ENV['GMAIL_USERNAME']
    form.password = ENV['SAZENI_PASSWORD']
  end.submit
  
  #free tipy sections
  free_tipy = a.click(my_page.link_with(:text => /Free tipy/))
  
  #iteration over all free tips sections except first section
  for i in 2..12
    free_tipy = a.click(free_tipy.link_with(:text => /#{i}/))
    html = free_tipy.body.delete "\n"
    html.scan(/<tr class="(green)">(.*?)<\/tr>/) {|w| w[1].scan(/<td>(.*?)<\/td>/){ |x| arrOK.concat x }  }
    html.scan(/<tr class="(red)">(.*?)<\/tr>/) {|w| w[1].scan(/<td>(.*?)<\/td>/){ |y| arrNotOK.concat y }  }
  end
end

puts "FREE TIPY STATISTICS: page 2..12"
puts "celkem prochranych: #{arrNotOK.count/7}" #7 = count of <td> tags in <tr> <==> count of <tr> tags
puts "celkem vyhranych: #{arrOK.count/7}"
puts "cista vyhra +- #{win(arrOK)*1000 - (arrNotOK.count/7)*1000 - (arrOK.count/7)*1000}"



