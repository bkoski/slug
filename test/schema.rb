ActiveRecord::Schema.define(:version => 1) do

  create_table "articles", :force => true do |t|
    t.column "headline", "string"
    t.column "slug", "string"
  end
  
  create_table "people", :force => true do |t|
    t.column "name", "string"
    t.column "web_slug", "string"
  end
  
end