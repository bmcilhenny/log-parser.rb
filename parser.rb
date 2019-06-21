require 'byebug'
lines = File.readlines './2014-09-03.log'
# lines = File.readlines 'test.log'


missing_errors_hash_map = Hash.new(0)
db_tables_hash_map = Hash.new(0)
# length = 0
time_served = 0.0
pages_served = 0
heroku_routers = 0
total_sql = 0

lines.each_with_index do |line, idx|
    
    # 1 - hash map 404_urls
    missing_error = line.match?(/status=404/)
    if missing_error
        path = line.scan(/path=\"(.*?)\"/).flatten.first
        host = line.scan(/host=([^\s]+)/).flatten.first
        missing_errors_hash_map[host + path] += 1 unless path.nil? || host.nil?
    end

    # 2 - sum total services ( not including connect time)
    service = line.scan(/service=(\d+)ms/).flatten.first
    # connect = line.scan(/connect=(\d+)ms/).flatten.first
    page_was_served = line.match?(/heroku\/router/)
    time_served += service.to_i unless service.nil?
    # time_served += (service.to_i + connect.to_i) unless service.nil?
    pages_served += 1 if page_was_served
    # length += 1 if heroku_router_match

    # 3 - most loaded db
    db_table = line.scan(/FROM \"(.*?)"|JOIN \"(.*?)"/).flatten.compact
    # db_table += line.scan(/JOIN \"(.*?)"/).flatten
    db_table.each{|db_table| db_tables_hash_map[db_table] += 1}

    # used this line to check if line had heroku/router
    # heroku_router = line.match?(/heroku\/router/)
    # if heroku_router
    #     heroku_routers += 1 if heroku_router
    #     has_sql = line.match?(/SELECT/)
    #     total_sql += 1 if has_sql
    # end

end

avg_serv = (time_served/pages_served).round(2)
most_common_db_table = db_tables_hash_map.max_by{|k,v| v}.first


puts "404 url error breakdown", missing_errors_hash_map
puts "Avg time took to serv (ms)", avg_serv
puts "most common Database table loaded", most_common_db_table
