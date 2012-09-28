# encoding: utf-8

require 'logger'
require 'bundler'
Bundler.setup
require 'mechanize'
require 'nokogiri'
require 'ostruct'


class RgFootball
  ROOT_PATH = "http://rgfootball.net"

  def initialize(login, password)
    @login, @password = login, password
    @agent = create_mechanize_agent
    login
  end

  def find_torrents(q)
    doc = Nokogiri::HTML(@agent.post(ROOT_PATH + "/tracker.php", :nm => q).content)

    result = []

    doc.css("#tor-tbl tr")[1..-2].each do |tr|
      fields = tr.css("td").map(&:text).map(&:strip)

      result << OpenStruct.new({ 
        :category => fields[2],
        :title => fields[3],
        :author => fields[4],
        :size => fields[5].to_i,
        :seeders => fields[6].to_i,
        :leechers => fields[7].to_i,
        :created_at_timestamp => fields[9].to_i,
      })
    end

    result
  end

  private
   
  def create_mechanize_agent
    agent = Mechanize.new
    agent.user_agent_alias = 'Linux Firefox'
    agent.follow_meta_refresh = true
    agent.redirect_ok = true
    agent.log = Logger.new "mech.log"

    agent
  end

  def login
    @agent.get(ROOT_PATH) do |page|
      page.form_with( :action => "./login.php") do |form|
        form.field_with( :name => "login_username" ).value = @login
        form.field_with( :name => "login_password" ).value = @password
        form.click_button
      end
    end
  end
end

tracker = RgFootball.new "APIMan", "lowkick"

p tracker.find_torrents("Милан").sort_by(&:seeders).reverse[0..2]

