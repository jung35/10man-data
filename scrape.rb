require 'logger'
require 'open-uri'
require 'nokogiri'
require 'uri'
require 'json'

logger = Logger.new(STDOUT)
matches = []

line_num = 0

File.readlines('MatchList').each do |line|
  url = line.strip
  match_data = {
    :url    => url,
    :team1  => [],
    :team2  => [],
    :scores => {
      :team1 => nil,
      :team2 => nil
    },
    :map    => nil
  }

  begin
    html = Nokogiri::HTML(open(url))
  rescue
    logger.warn("could not fetch match link: #{url}")
    next
  end

  logger.warn("Now parsing: #{url}")

  match_data[:map] = html.xpath('//*[@id="match-container"]/div[2]/div/text()').to_s.match(/(?<map>de_\w+)/)[:map]

  (1..2).each do |i|
    team_el = html.xpath("//*[@id='match-container']/div[1]/div[#{i}]/table/tr")
    team_score = html.xpath("//*[@id='match-container']/div[2]/div/div[#{i}]/text()").to_s.to_i

    team_el.shift

    team_player_list = []

    team_el.each do |row|
      player_el = row.xpath('td')

      player_name_el = player_el[0].xpath('a')
      player_id = player_name_el.map {|link| link['href']}[0].to_s.match(/(?<id>\d+)/)[:id].to_i
      player_name = player_name_el.xpath('text()').to_s

      player_data = {
        :id      => player_id,
        :name    => player_name,
        :kills   => player_el[1].xpath('text()').to_s.to_i,
        :assists => player_el[2].xpath('text()').to_s.to_i,
        :death   => player_el[3].xpath('text()').to_s.to_i,
        :flash   => player_el[4].xpath('text()').to_s.to_i,
        :adr     => player_el[5].xpath('text()').to_s.to_i,
        :hltv    => player_el[6].xpath('text()').to_s.to_f,
        :hs      => player_el[7].xpath('text()').to_s.to_f,
        :ck      => player_el[8].xpath('text()').to_s.to_i,
        :bp      => player_el[9].xpath('text()').to_s.to_i,
        :bd      => player_el[10].xpath('text()').to_s.to_i,
        :fed     => player_el[11].xpath('text()').to_s.to_i
      }

      team_player_list.push(player_data)
    end

    match_data["team#{i}".to_sym] = team_player_list
    match_data[:scores]["team#{i}".to_sym] = team_score
  end

  matches.push(match_data)

end

puts 'Saving data'
File.open('matches.json', 'w') do |f|
  f.write(JSON.pretty_generate(matches))
end