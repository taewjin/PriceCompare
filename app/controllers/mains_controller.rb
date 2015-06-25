
require "open-uri"



class MainsController < ApplicationController

	def new
		render '/mains/new'
	end
	def create		

		@search_key = params[:search_key]		
			item_plus = params[:search_key]
			item_underscore = params[:search_key]
			i = 0
			for i in 0..item_plus.length
				if item_plus[i] == " "
					item_underscore[i] = "_"
					item_plus[i] = "+"
				end
				i = i + 1
			end

		url = "http://www.amazon.com/s/ref=nb_sb_noss_1?url=search-alias%3Daps&field-keywords=#{item_plus}"
		amazon_dump = Array.new
		amazon_price = Array.new
		amazon_image = Array.new
		

		amazon_page = Nokogiri::HTML(open(url))
		amazon_search_result = amazon_page.css('.s-result-item')

		amazon_search_result.each do |item|		
			amazon_image.push(item.css('a.a-link-normal.a-text-normal img').map { |img| img['src'] })
			amazon_dump.push(item.css(".a-size-medium.s-inline.s-access-title.a-text-normal").text)
			if item.css('.a-size-base.a-color-price.s-price.a-text-bold').nil?
				amazon_dump.pop()
			else
				amazon_price.push(item.css('.a-size-base.a-color-price.s-price.a-text-bold').text)
			end
		end
		@amazon = amazon_dump.zip(amazon_price,	amazon_image)


		url = "http://seattle.craigslist.org/search/sss?query=#{item_underscore}&sort=rel"
		craigslist_dump = Array.new
		craigslist_price = Array.new
		craigslist_page = Nokogiri::HTML(open(url))
		craigslist_search_result = craigslist_page.css(".row")
		craigslist_search_result.each do |item|
			craigslist_dump.push(item.at_css('.hdrlnk').text.strip)
			if item.at_css('.l2 .price').nil?
				craigslist_dump.pop()
			else
		  		craigslist_price.push(item.at_css('.l2 .price').text.strip)
			end
		  
		end

		@craigslist = craigslist_dump.zip(craigslist_price)


		url = "http://www.walmart.com/search/search-ng.do?search_constraint=0&ic=48_0&search_query=#{item_underscore}&Find.x=0&Find.y=0&Find=Find"
		walmart_dump = Array.new
		walmart_price = Array.new
		walmart_page = Nokogiri::HTML(open(url))
		walmart_page.css(".js-tile.tile-landscape").each do |item|
			walmart_dump.push(item.at_css('.js-product-title').text)
			if item.at_css('.price-display').nil?
				walmart_price.push("N/A")
			else
		  		walmart_price.push(item.at_css('.price-display').text)
		  	end
		end
		
		@walmart = walmart_dump.zip(walmart_price)


		url = "http://www.bestbuy.com/site/searchpage.jsp?st=#{item_plus}&_dyncharset=UTF-8&id=pcat17071&type=page&sc=Global&cp=1&nrp=15&sp=&qp=&list=n&iht=y&usc=All+Categories&ks=960&keys=keys"
		bestbuy_dump = Array.new
		bestbuy_price = Array.new
		bestbuy_page = Nokogiri::HTML(open(url))
		bestbuy_page.css(".list-item-info").each do |item|
			bestbuy_dump.push(item.at_css('.sku-title').text)
			if item.at_css('.medium-item-price').nil?
				bestbuy_price.push("N/A")
			else
		  		bestbuy_price.push(item.at_css('.medium-item-price').text)
		  	end
		end
		
		@bestbuy = bestbuy_dump.zip(bestbuy_price)




		# LOWEST price

		#Craigslist
		craigslist_lowest_url = "http://seattle.craigslist.org/search/sss?sort=priceasc&query=#{item_underscore}"
		craigslist_lowest_dump = Nokogiri::HTML(open(craigslist_lowest_url))
		if (!craigslist_lowest_dump.at_css(".hdrlnk"))
			@craigslist_item_lowest_title = "Couldnt find any lowest priced item."
		else
		@craigslist_item_lowest_title = craigslist_lowest_dump.at_css(".hdrlnk").text
		  @craigslist_item_lowest_price= craigslist_lowest_dump.at_css("span.price").text
		 craigslist_img_link= craigslist_lowest_dump.css('p.row a').map { |link| link['href'] }
		@craigslist_image_link =  craigslist_img_link.first
		craigslist_item_image= craigslist_lowest_dump.css('div.swipe-wrap div').map { |img| img.map }		
		@craigslist_lowest_item_img = craigslist_item_image.first
		end

		# Walmart
		walmart_lowest_url = "http://www.walmart.com/search/?query=#{item_underscore}&sort=price_low"
		walmart_lowest_dump = Nokogiri::HTML(open(walmart_lowest_url))
		if (!walmart_lowest_dump.at_css(".js-product-title"))
			@walmart_item_lowest_title = "Couldnt find any lowest priced item."
		else
	    @walmart_item_lowest_title = walmart_lowest_dump.at_css(".js-product-title").text 
	    @walmart_item_lowest_price = walmart_lowest_dump.at_css(".price-display").text
	    # @walmart_item_lowest_image = walmart_lowest_dump.css(".js_product-image").first 
	    walmart_img_link = walmart_lowest_dump.css('h4.tile-heading a').map { |link| link['href'] }
	    @walmart_image_link = walmart_img_link.first
	    walmart_item_image = walmart_lowest_dump.css('a.js-product-image img').map { |img| img['src'] }
	    @walmart_lowest_item_img =  walmart_item_image.first
		end
			render '/mains/index'
	end

end
