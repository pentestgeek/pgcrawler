#!/usr/bin/env ruby
require 'net/http'
require 'rubygems'
require 'nokogiri'
require 'open-uri'


# This is the main Spider Class
class Spider


  attr_accessor :address, :port, :path


  def initialize(address, port = 80)
    @urls = Array.new
    @visited_urls = Array.new
    self.address = address
    self.path = '/'
    self.port = 80
  end


  # 2. This method is called to create the HTTP connection to the target and start spidering
  def connect_to_address
    puts "[.] Collecting initial URLs from the target."
    connection = Net::HTTP.new(self.address)
    headers, body = connection.get(self.path)
    if headers.code == "200"
      # 3. Send the returned page body to the parsing function to search for additional URLs.  Method returns an array value.
      urls = parse_source(body)
      if urls
        puts "[.] Collected #{urls.length} URLs."
        # 5. Send the urls to the spider method
        puts "[.] Spidering URLs."
        urls.each do |url|
          spider(url) if !@visited_urls.include?(url)
        end
      else
        puts "[-] No URLs found."
        exit! 
      end
    else
      puts "[-] Make sure the target is a website."
    end
    return @visited_urls
  end


  # 4. Find all the links in the page and add them to the @urls array
  def parse_source(body)
    html_doc = Nokogiri::HTML(body) 
    html_doc.xpath('//a/@href').each do |links|
      @urls << links.content
    end
    return @urls
  end


  def spider(url)
    puts "[.] Spidering #{url}."
    Thread.new {
      if new_page = Nokogiri::HTML(open(url))
        new_page.xpath('//a/@href').each do |link|
          @urls << link.content
          spider(link.content)
        end
      end
    }
    @visited_urls << url 
  end
  

end


#This controles execution flow
def main_function
  # 1. Create a new instance of the Spider class and pass it the URL provided at runtime
  new_spider = Spider.new(ARGV[0])
  spider = new_spider.connect_to_address
  puts "[+] Finished processesing #{spider.length} URLs from the target."
end


main_function
