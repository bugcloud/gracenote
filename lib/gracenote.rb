require "gracenote/version"
require 'net/http'
require 'multi_xml'
require 'xml_templates'

class Gracenote
  attr_accessor :user_id, :client_id

  def initialize(client_id, user_id = nil)
    @client_id = client_id
    if user_id.nil?
      xml = %Q|<QUERIES>
           <QUERY CMD="REGISTER">
             <CLIENT>#{@client_id}</CLIENT>
           </QUERY>
         </QUERIES>|
      body = MultiXml.parse post(xml)
      @user_id = body["RESPONSES"]["RESPONSE"]["USER"]
    else
      @user_id = user_id
    end
  end


  def basic_track_search(artist, album_title, track_title)
    xml = XmlTemplates.album_search % {client_id: @client_id, user_id: @user_id, artist: artist, album_title: album_title, track_title: track_title}
    response = MultiXml.parse post(xml)
    response
  end

  def artist_image(gnid)
    xml = XmlTemplates.album_fetch % {client_id: @client_id, user_id: @user_id, gnid: gnid}
    response = MultiXml.parse post(xml)
    response['RESPONSES']['RESPONSE']['ALBUM']['URL']['__content__']
  end

  #
  # Search album cover art with artist name and album title.
  # @param [Hash] Options
  #   Options
  #     :size => the size of cover art. the expected values are :large / :xlarge / :small / :medium / :thumbnail and the default value is :medium
  def album_image(artist, album_title, *args)
    options = args.last.is_a?(Hash) ? args.pop : { size: :medium }
    xml = XmlTemplates.cover_search % {client_id: @client_id, user_id: @user_id, artist: artist, album_title: album_title, size: options[:size].to_s.upcase}
    response = MultiXml.parse post(xml)
    response['RESPONSES']['RESPONSE']['ALBUM']['URL']['__content__']
  end

  private

  def uri
    URI.parse base_url
  end

  def post xml
    req = Net::HTTP::Post.new(uri.path)
    req.body = xml
    res = http.request(req)
    res.body
  end

  def http
    return @http if @http
    @http = Net::HTTP.new(uri.host, uri.port)
    @http.use_ssl = true
    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @http.ssl_version = :SSLv3
    @http
  end

  def base_url
    "https://c#{@client_id.split('-').first}.web.cddbp.net/webapi/xml/1.0/"
  end
end
