require 'sinatra'
require 'redis'
$redis = Redis.new(host: ENV["REDIS"])

# Management UI
get '/manage' do
  erb :management
end

# API
post "/api/stub/new" do
  stub_key = params["stub"]
  if $redis.keys("stub:#{stub_key}").empty?
    $redis.hset("stub:#{stub_key}", "stub", params["stub"], "url", params["url"])
    $redis.rpush("stubs", stub_key)
  end
  redirect "/manage", 303
end

get "/api/stubs" do
  arr = []
  $redis.keys("stub:*").each do |key|
    arr << $redis.hgetall(key)
  end
  return arr.filter {|x| x["stub"] }.to_json
end

delete "/api/stub/*" do
  cur_stub = URI.decode_uri_component(params["splat"][0])
  puts params, cur_stub
  $redis.del("stub:" + cur_stub)
  $redis.lrem("stubs", 1, cur_stub)
  redirect "/manage", 303
end

get "/" do
  erb "Listing"
end

get '/*' do
  all_stubs = $redis.lrange("stubs", 0, -1)
  cur_stub = params["splat"][0]

  all_stubs.each do |test_stub|
    test_stub_pattern = Mustermann.new(test_stub, type: :template)
    if test_stub_pattern === cur_stub
      # We have a match
      cur_params = test_stub_pattern.params(cur_stub)
      redirect_url = URI.decode_uri_component(Mustermann.new($redis.hget("stub:#{test_stub}", "url"), type: :template).expand(cur_params))
      redirect redirect_url, 303
    end
  end
  # We don't have any matches
  erb :unknown
end