require 'sinatra'
require 'redis'
$redis = Redis.new

# Management UI
get '/manage' do
  redirect "/manage/index.html", 303
end

# API
post "/api/stub/new" do
  stub_key = params["stub"].split("/")[0]
  if $redis.keys("stub:#{stub_key}").empty?
    $redis.hset("stub:#{stub_key}", "stub", params["stub"], "url", params["url"])
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

delete "/api/stub/:stub" do
  $redis.del("stub:" + params[:stub])
  redirect "/manage", 303
end

# The actual redirect when the hostname starts with 'go'
get '/*', host_name: /^go(.*)/ do
  # Clean the stub
  splats = params["splat"][0].split("/")
  search_stub = splats[0]
  aux_val = splats[1..].reverse

  url = $redis.hget("stub:#{search_stub}", "url")
  if url
    while url.match(/%s/) and not aux_val.empty?
      url.sub!(/%s/, aux_val.pop)
    end
    redirect url, 303
    # "Redirect to #{url} ..."
  else
    [400, "Unknown link"]
  end
end