ActiveRecord::Schema.define(:version => 1) do
  create_table "articles", :force => true do |t|
    t.column "headline", "string", null: false
    t.column "section", "string"
    t.column "slug", "string", null: false
    t.column "type", "string"
    t.index ["slug"], name: "index_articles_on_slug", unique: true
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

  create_table "generations", :force => true do |t|
    t.column "title", "string"
    t.column "slug", "string", null: false
  end

  # table with no slug column
  create_table "orphans", :force => true do |t|
    t.column "name", "string"
    t.column "location", "string"
  end
end
