# encoding: utf-8
require 'test_helper'

describe Slug do
  before do
    Article.delete_all
  end

  describe 'slug' do
    it "bases slug on specified source column" do
      article = Article.create!(:headline => 'Test Headline')
      assert_equal 'test-headline', article.slug
    end

    it "bases slug on specified source column, even if it is defined as a method rather than database attribute" do
      article = Event.create!(:title => 'Test Event', :location => 'Portland')
      assert_equal 'test-event-portland', article.slug
    end

    it "bases to_param on slug" do
      article = Article.create!(:headline => 'Test Headline')
      assert_equal(article.slug, article.to_param)
    end

    it "does not impact lookup of model with no slug column" do
      orphan = Orphan.create!(:name => 'Oliver')
      query = orphan.to_param
      assert_equal(orphan.id.to_s, query)
    end

    describe "slug column" do
      it "saves slug to 'slug' column by default" do
        article = Article.create!(:headline => 'Test Headline')
        assert_equal 'test-headline', article.slug
      end

      it "saves slug to :column specified in options" do
        Person.delete_all
        person = Person.create!(:name => 'Test Person')
        assert_equal 'test-person', person.web_slug
      end
    end
  end

  describe "column validations" do
    it "raises ArgumentError if an invalid source column is passed" do
      Company.slug(:invalid_source_column)
      assert_raises(ArgumentError) { Company.create! }
    end

    it "raises an ArgumentError if an invalid slug column is passed" do
      Company.slug(:name, :column => :bad_slug_column)
      assert_raises(ArgumentError) { Company.create! }
    end
  end

  describe 'generates a generic slug' do
    before do
      Generation.delete_all
    end

    it "if source column is empty" do
      generation = Generation.create!
      assert_equal 'generation', generation.slug
    end

    it "if normalization makes source value empty" do
      generation = Generation.create!(:title => '$$$')
      assert_equal 'generation', generation.slug
    end

    it "if source value contains no Latin characters" do
      generation = Generation.create!(:title => 'ローマ字がない')
      assert_equal 'generation', generation.slug
    end
  end

  describe 'validation' do
    it "sets validation error if source column is empty" do
      article = Article.create
      assert !article.valid?
      assert article.errors[:slug]
    end

    it "sets validation error if normalization makes source value empty" do
      article = Article.create(:headline => '$$$')
      assert !article.valid?
      assert article.errors[:slug]
    end

    it "validates slug format on save" do
      article = Article.create!(:headline => 'Test Headline')
      article.slug = 'A BAD $LUG.'

      assert !article.valid?
      assert article.errors[:slug].present?
    end

    it "validates uniqueness of slug by default" do
      Article.create!(:headline => 'Test Headline')
      article2 = Article.create!(:headline => 'Test Headline')
      article2.slug = 'test-headline'

      assert !article2.valid?
      assert article2.errors[:slug].present?
    end

    it "uses validate_uniqueness_if proc to decide whether uniqueness validation applies" do
      Post.create!(:headline => 'Test Headline')
      article2 = Post.new
      article2.slug = 'test-headline'

      assert article2.valid?
    end
  end

  it "doesn't overwrite slug value on create if it was already specified" do
    a = Article.create!(:headline => 'Test Headline', :slug => 'slug1')
    assert_equal 'slug1', a.slug
  end

  it "doesn't update the slug even if the source column changes" do
    article = Article.create!(:headline => 'Test Headline')
    article.update_attributes!(:headline =>  'New Headline')
    assert_equal 'test-headline', article.slug
  end

  describe "resetting a slug" do
    before do
      @article = Article.create(:headline => 'test headline')
      @original_slug = @article.slug
    end

    it "maintains the same slug if slug column hasn't changed" do
      @article.reset_slug
      assert_equal @original_slug, @article.slug
    end

    it "changes slug if slug column has updated" do
      @article.headline = "donkey"
      @article.reset_slug
      refute_equal(@original_slug, @article.slug)
    end

    it "maintains sequence" do
      @existing_article = Article.create!(:headline => 'world cup')
      @article.headline = "world cup"
      @article.reset_slug
      assert_equal 'world-cup-1', @article.slug
    end
  end

  describe "slug normalization" do
    before do
      @article = Article.new
    end

    it "lowercases strings" do
      @article.headline = 'AbC'
      @article.save!
      assert_equal "abc", @article.slug
    end

    it "replaces whitespace with dashes" do
      @article.headline = 'a b'
      @article.save!
      assert_equal 'a-b', @article.slug
    end

    it "replaces 2spaces with 1dash" do
      @article.headline = 'a  b'
      @article.save!
      assert_equal 'a-b', @article.slug
    end

    it "removes punctuation" do
      @article.headline = 'abc!@#$%^&*•¶§∞¢££¡¿()><?""\':;][]\.,/'
      @article.save!
      assert_match 'abc', @article.slug
    end

    it "strips trailing space" do
      @article.headline = 'ab '
      @article.save!
      assert_equal 'ab', @article.slug
    end

    it "strips leading space" do
      @article.headline = ' ab'
      @article.save!
      assert_equal 'ab', @article.slug
    end

    it "strips trailing dashes" do
      @article.headline = 'ab-'
      @article.save!
      assert_match 'ab', @article.slug
    end

    it "strips leading dashes" do
      @article.headline = '-ab'
      @article.save!
      assert_match 'ab', @article.slug
    end

    it "remove double-dashes" do
      @article.headline = 'a--b--c'
      @article.save!
      assert_match 'a-b-c', @article.slug
    end

    it "doesn't modify valid slug strings" do
      @article.headline = 'a-b-c-d'
      @article.save!
      assert_match 'a-b-c-d', @article.slug
    end

    it "doesn't insert dashes for periods in acronyms, regardless of where they appear in string" do
      @article.headline = "N.Y.P.D. vs. N.S.A. vs. F.B.I."
      @article.save!
      assert_match 'nypd-vs-nsa-vs-fbi', @article.slug
    end

    it "doesn't insert dashes for apostrophes" do
      @article.headline = "Thomas Jefferson's Papers"
      @article.save!
      assert_match 'thomas-jeffersons-papers', @article.slug
    end

    it "preserves numbers in slug" do
      @article.headline = "2010 Election"
      @article.save!
      assert_match '2010-election', @article.slug
    end
  end

  describe "diacritics handling" do
    before do
      @article = Article.new
    end

    it "strips diacritics" do
      @article.headline = "açaí"
      @article.save!
      assert_equal "acai", @article.slug
    end

    it "strips diacritics correctly " do
      @article.headline  = "ÀÁÂÃÄÅÆÇÈÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ"
      @article.save!
      expected = "aaaaaaaeceeeiiiidnoooooouuuuythssaaaaaaaeceeeeiiiidnoooooouuuuythy".split(//)
      output = @article.slug.split(//)
      output.each_index do |i|
        assert_equal expected[i], output[i]
      end
    end
  end

  describe "sequence handling" do
    it "doesn't add a sequence if saving first instance of slug" do
      article = Article.create!(:headline => 'Test Headline')
      assert_equal 'test-headline', article.slug
    end

    it "assigns a -1 suffix to the second instance of the slug" do
      Article.create!(:headline => 'Test Headline')
      article_2 = Article.create!(:headline => 'Test Headline')
      assert_equal 'test-headline-1', article_2.slug
    end

    it 'assigns a -2 suffix to the third instance of the slug containing numbers' do
      2.times { |i| Article.create! :headline => '11111' }
      article_3 = Article.create! :headline => '11111'
      assert_equal '11111-2', article_3.slug
    end

    it "assigns a -12 suffix to the thirteenth instance of the slug" do
      12.times { |i| Article.create!(:headline => 'Test Headline') }
      article_13 = Article.create!(:headline => 'Test Headline')
      assert_equal 'test-headline-12', article_13.slug

      12.times { |i| Article.create!(:headline => 'latest from lybia') }
      article_13 = Article.create!(:headline => 'latest from lybia')
      assert_equal 'latest-from-lybia-12', article_13.slug
    end

    it "ignores partial matches when calculating sequence" do
      article_1 = Article.create!(:headline => 'Test Headline')
      assert_equal 'test-headline', article_1.slug
      article_2 = Article.create!(:headline => 'Test')
      assert_equal 'test', article_2.slug
      article_3 = Article.create!(:headline => 'Test')
      assert_equal 'test-1', article_3.slug
      article_4 = Article.create!(:headline => 'Test')
      assert_equal 'test-2', article_4.slug
    end

    it "knows about single table inheritance" do
      article = Article.create!(:headline => 'Test Headline')
      story = Storyline.create!(:headline => article.headline)
      assert_equal 'test-headline-1', story.slug
    end

    it "correctly slugs when a slug is a substring of another" do
      rap_metal = Article.create!(:headline => 'Rap Metal')
      assert_equal 'rap-metal', rap_metal.slug

      rap = Article.create!(:headline => 'Rap')
      assert_equal('rap', rap.slug)
    end

    it "applies sequence logic correctly when the slug is a substring of another" do
      rap_metal = Article.create!(:headline => 'Rap Metal')
      assert_equal 'rap-metal', rap_metal.slug

      Article.create!(:headline => 'Rap')
      second_rap = Article.create!(:headline => 'Rap')
      assert_equal('rap-1', second_rap.slug)
    end
  end
end
