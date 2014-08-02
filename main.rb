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
`rm IMG/JD/*.*`



$agent = Mechanize.new

# page = agent.get('http://t.qq.com/wudixiaotie')
# homepage = agent.get('http://jd.com')

def analyze_and_save(div, coll)
  item = {}
  item[:name] = div.search("div[@class='p-name']").text

  # price
  item[:current_price] = 0
  item[:original_price] = 0

  
  coll.insert(item)

  img_url = div.search("div[@class='p-img']/a/img").attribute("data-lazyload").value
  img_extension = img_url.split('.').last
  img_path = $agent.get(img_url).save!("IMG/JD/#{item[:_id].to_s}.#{img_extension}")

  img_file = File.open(img_path)
  while img_file.size == 0
    $agent.get(img_url).save!(img_path)
    img_file = File.open(img_path)
  end

  item[:img_path] = img_path

  coll.update( { "_id" => item[:_id] }, item)
end

keyword = "手机"

# (1..2).each do |page_num|
#   list_page_p1 = $agent.get("http://search.jd.com/Search?keyword=#{keyword}&enc=utf-8&page=#{page_num}")

#   i = 0

#   list_page_p1.search("div[@class=lh-wrap]").each do |div|
#     analyze_and_save(div, $coll)

#     i += 1
#   end

#   list_page_p2 = $agent.get("http://search.jd.com/s.php?keyword=#{keyword}&enc=utf-8&qr=&qrst=UNEXPAND&et=&rt=1&click=&psort=&page=#{page_num + 1}&scrolling=y&start=#{i}&tpl=1_M&vt=1")


#   list_page_p2.search("div[@class=lh-wrap]").each do |div|
#     analyze_and_save(div, $coll)
#   end
# end