class Scrapper
  	#ici on recupere l'email d'une mairie à partir de son URL
  def get_townhall_email(townhall_url)
  	page = Nokogiri::HTML(open(townhall_url))
    	email = page.xpath('//td[contains(text(), "@")]').text
    	puts email
  end
    	get_townhall_email("http://annuaire-des-mairies.com/95/ableiges.html")
    
    #ici on recupere toutes les URLs des villes du Val d'Oise
  def get_townhall_urls
     	names_arr = []
    	emails_arr = []
    	urls_arr = []
    	
	page = Nokogiri::HTML(open("http://annuaire-des-mairies.com/val-d-oise.html"))
	names = page.xpath('//tr/td/p/a').each do |name|#Voici la liste du nom des villes
	names_arr.push(name.text)
	puts names_arr 
   end
		
	urls = page.xpath('//a[contains(@href, "95")]/@href').each do |url|
	urls_arr.push(url.value)
			   
	end

	urls_arr.each do |url|
	com = "http://annuaire-des-mairies.com/"+url
	emails_arr.push(get_townhall_email(com))#Voici la liste des emails pour chaque ville
			
	end

	my_hash = names_arr.zip(emails_arr).to_h
	return my_hash

   def file_json(my_hash)
	File.open('./db/emails.json', "w") do |json|
	json << my_hash.to_json
   	end
   end

	data = get_townhall_urls
	file_json(data)
	
#-----------------------------------------------------------------------------------------------------------------------
		
   def spreadsheet
	index = 1
	session GoogleDrive::Session.from_config("config.json")
	ws = session.spreadsheet_by_key("157NepG10EpvxtEhokrNWlma16BjTeD8bQDovwKxQlwY").worksheets[0]
	@@my_hash.each_key do |key|
	ws[index, 1]	= key
	ws[index, 2] = @@my_hash[key]
	index += 1
	 end
	ws.save
	ws.reload
   end
   def csv
	 File.open("./db/email.csv", "w") do |f|
      f << @@my_hash.map { |c| c.join(",")}.join("\n")
    end   
   end
end
Scrapper.new
Scrapper.spreadsheet
Scrapper.csv
Scrapper.new
