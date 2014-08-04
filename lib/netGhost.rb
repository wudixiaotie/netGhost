require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
include Mongo

# mongodb
$db = MongoClient.new("localhost", 27017).db("netGhost")
# auth = db.authenticate(my_user_name, my_password)



$agent = Mechanize.new

# page = agent.get('http://t.qq.com/wudixiaotie')
# homepage = agent.get('http://jd.com')

def analyze_and_save(li, coll)
  begin
    if li.attributes.include? "sku"
      item = {}
      item[:id] = li.attributes["sku"].value
      item[:name] = li.search("div[@class='p-name']").text

      # price
      item[:current_price] = 0
      item[:original_price] = 0
      price_url = "http://p.3.cn/prices/mgets?skuIds=J_#{item[:id]}"
      price = JSON.parse($agent.get(price_url).body).first

      unless price.nil?
        item[:current_price] = price["p"]
        item[:original_price] = price["m"]
      end

      
      coll.insert(item)

      img_url = li.search("div[@class='p-img']/a/img").attribute("data-lazyload").value
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
  rescue
    # logger
    binding.pry
  end
end

keyword = "手机"
coll = $db.collection("testData")
# drop collection in mongo
coll.drop
# remove all image file that downloaded before
`rm ./IMG/JD/*.*`

(1..2).each do |page_num|
  list_page_p1 = $agent.get("http://search.jd.com/Search?keyword=#{keyword}&enc=utf-8&page=#{page_num}")

  i = 0

  list_page_p1.search("ul[@class='list-h clearfix'] li").each do |li|
    analyze_and_save(li, coll)

    i += 1
  end

  list_page_p2 = $agent.get("http://search.jd.com/s.php?keyword=#{keyword}&enc=utf-8&qr=&qrst=UNEXPAND&et=&rt=1&click=&psort=&page=#{page_num + 1}&scrolling=y&start=#{i}&tpl=1_M&vt=1")

  list_page_p2.search("ul[@class='list-h clearfix'] li").each do |li|
    analyze_and_save(li, coll)
  end
end