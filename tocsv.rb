require 'json'
raise Exception, 'you must provide a json file' unless ARGV[0]

json = JSON.parse(File.open(ARGV[0]).read)

player_list = json["player_list"]
match_data = json["match_data"]

csvString = "+"
player_list.each{|p| csvString += ",\"#{p["name"]}\""}
csvString += "\n"

player_list.each do |p|
  csvString += "\"#{p["name"]}\""

  player_list.each do |q|
    if p["id"] == q["id"]
      csvString += ","
      next
    end

    data = match_data["#{p["id"]}"]["#{q["id"]}"]

    total = data["win"] + data["lose"] + data["tie"]

    if total == 0
      csvString += ",0"
      next
    end

    csvString += ",#{data["win"].to_f / total}"
  end

  csvString += "\n"
end

puts 'Saving data'
File.open("#{ARGV[0]}_csv.csv", 'w') do |f|
  f.write(csvString)
end