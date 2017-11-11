require 'json'
require 'set'

file = File.read('matches.json')
matches = JSON.parse(file)
player_list_set = Set.new 

matches.each do |list|
  (1..2).each do |i|
    list["team#{i}"].each do |player_data|
      player_list_set.merge([{id: player_data["id"], name: player_data["name"]}])
    end
  end
end
player_list = player_list_set.to_a

count = player_list.length

player_opponent = {}

(0..count-1).each do |row|
  player_opponent[player_list[row][:id]] = {}
  (0..count-1).each do |col|
    next if row == col
    player_opponent[player_list[row][:id]][player_list[col][:id]] = { win: 0, lose: 0, tie: 0 }
  end
end

matches.each do |list|
  (1..2).each do |i|
    scores = list["scores"]
    won = scores["team#{i}"] > scores["team#{i%2 + 1}"]
    lost = scores["team#{i}"] < scores["team#{i%2 + 1}"]
    tied = scores["team#{i}"] == scores["team#{i%2 + 1}"]

    list["team#{i}"].each do |row_player|
      list["team#{i%2 + 1}"].each do |col_player|
        temp_syn = player_opponent[row_player["id"]][col_player["id"]]

        temp_syn[:win] += (won ? 1 : 0)
        temp_syn[:lose] += (lost ? 1 : 0)
        temp_syn[:tie] += (tied ? 1 : 0)

        player_opponent[row_player["id"]][col_player["id"]] = temp_syn
      end
    end
  end
end

data = {
  :player_list => player_list,
  :match_data => player_opponent
}

puts 'Saving data'
File.open('player_opponent.json', 'w') do |f|
  f.write(JSON.pretty_generate(data))
end