require 'byebug'
lines = File.readlines './2014-09-03.log'
# lines = File.readlines 'test.log'


missing_errors_hash_map = Hash.new(0)
db_tables_hash_map = Hash.new(0)
length = lines.length
total_serv = 0.0

def four_o_four_hash_map(line)
    url = line.scan(/path=\"(.*?)\"/).first
    url = line.scan(/host=([^\s]+)/)
    missing_errors[url] += 1 unless url.empty?
end

heroku_routers = 0
total_sql = 0

lines.each_with_index do |line, idx|
    # 1 - hash map 404_urls
    missing_error = line.match?(/status=404/)
    if missing_error
        path = line.scan(/path=\"(.*?)\"/).flatten.first
        host = line.scan(/host=([^\s]+)/).flatten.first
        missing_errors[host + path] += 1 unless path.nil? || host.nil?
    end
    server errors
    server_err = line.match?(/status=5\d\d/)

    # 2 - sum total services
    service = line.scan(/service=(\d+)ms/).flatten.first
    total_serv += service.to_i unless service.nil?

    # 3 - most loaded db
    db_table = line.scan(/FROM \"(.*?)"/).flatten
    db_table.each{|db_table| db_tables_hash_map[db_table] += 1}
    heroku_router = line.match?(/heroku\/router/)
    if heroku_router
        heroku_routers += 1 if heroku_router
        has_sql = line.match?(/SELECT/)
        total_sql += 1 if has_sql
    end

end

avg_serv = (total_serv/length).round(2)
most_common_db_table = db_tables_hash_map.max_by{|k,v| v}.first


puts missing_errors_hash_map
puts avg_serv
puts most_common_db_table
