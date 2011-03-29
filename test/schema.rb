ActiveRecord::Schema.define(:version => 1) do

  create_table "articles", :force => true do |t|
    t.column "headline", "string"
    t.column "section", "string"
    t.column "slug", "string"
  end
  
  create_table "people", :force => true do |t|
    t.column "name", "string"
    t.column "web_slug", "string"
  end
  
  create_table "companies", :force => true do |t|
    t.column "name", "string"
    t.column "slug", "string"
  end
  
  create_table "posts", :force => true do |t|
    t.column "headline", "string"
    t.column "slug", "string"
  end
  
  create_table "events", :force => true do |t|
    t.column "title", "string"
    t.column "location", "string"
    t.column "slug", "string"
  end 
  
  create_table "portfolios", :force => true do |t|    
  end
  
  create_table "projects", :force => true do |t|
    t.column "title", "string"
    t.column "slug", "string"
    t.column "portfolio_id", "integer"
  end
  
end