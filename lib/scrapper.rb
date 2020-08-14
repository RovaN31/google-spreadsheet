require 'nokogiri'
require 'open-uri'
require 'google_drive'
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
    	
		page = Nokogiri::HTML(open("http://annuaire-des-mairies.com/val-d-oise.html"))
		names = page.xpath('//tr/td/p/a').each do |name|#Voici la liste du nom des villes
				names_arr.push(name.text)
				puts names_arr 
			end
		
		urls = page.xpath('//a[contains(@href, "95")]/@href').each do |url|
		    emails_arr << get_townhall_email("http://annuaire-des-mairies.com/"+"#{url}")#Voici la liste des emails pour chaque ville
			
			end
			
			hash = names_arr.zip(emails_arr).to_h
			return hash
			JSON.open('emails.json') do |json|
				json << hash
			end

	end
	get_townhall_urls
#-----------------------------------------------------------------------------------------------------------------------
		
	def spreadsheet
		index = 1
		session GoogleDrive::Session.from_config("config.json")
		 ws = session.spreadsheet_by_key("157NepG10EpvxtEhokrNWlma16BjTeD8bQDovwKxQlwY").worksheets[0]

	end




	
end