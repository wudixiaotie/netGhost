require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
include Mongo

# mongodb
$db = MongoClient.new("localhost", 27017).db("netGhost")
# auth = db.authenticate(my_user_name, my_password)
$coll = $db.collection("testData")

# drop collection in mongo
$coll.drop
# remove all image file that downloaded before
# `rm IMG/JD/*.*`



$agent = Mechanize.new

keyword = "手机"

page_num = 1


list_page_p1 = $agent.get("http://search.jd.com/Search?keyword=#{keyword}&enc=utf-8&page=#{page_num}")

li = list_page_p1.search("ul[@class='list-h clearfix'] li")[0]

item = {}
item[:id] = li.attributes["sku"].value
item[:name] = li.search("div[@class='p-name']").text

# price
item[:current_price] = 0
item[:original_price] = 0


$coll.insert(item)

binding.pry