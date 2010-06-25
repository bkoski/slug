require File.dirname(__FILE__) + '/test_helper'

class TestSlug < Test::Unit::TestCase

  def setup
    Article.delete_all
    Person.delete_all
  end

  should "base slug on specified source column" do
    article = Article.create!(:headline => 'Test Headline')
    assert_equal 'test-headline', article.slug
  end

  should "base slug on specified source column, even if it is defined as a method rather than database attribute" do
    article = Event.create!(:title => 'Test Event', :location => 'Portland')
    assert_equal 'test-event-portland', article.slug
  end

  context "slug column" do
    should "save slug to 'slug' column by default" do
      article = Article.create!(:headline => 'Test Headline')
      assert_equal 'test-headline', article.slug
    end
    
    should "save slug to :column specified in options" do
      person = Person.create!(:name => 'Test Person')
      assert_equal 'test-person', person.web_slug
    end
  end

  context "column validations" do
    should "raise ArgumentError if an invalid source column is passed" do
      Company.slug(:invalid_source_column) 
      assert_raises(ArgumentError) { Company.create! }
    end

    should "raise an ArgumentError if an invalid slug column is passed" do
      Company.slug(:name, :column => :bad_slug_column)
      assert_raises(ArgumentError) { Company.create! }
    end
  end
  
  should "set validation error if source column is empty" do
    article = Article.create
    assert !article.valid?
    require 'ruby-debug'
    assert article.errors.on(:slug)
  end
  
  should "set validation error if normalization makes source value empty" do
    article = Article.create(:headline => '$$$')
    assert !article.valid?
    assert article.errors.on(:slug)
  end
  
  should "not update the slug even if the source column changes" do
    article = Article.create!(:headline => 'Test Headline')
    article.update_attributes!(:headline =>  'New Headline')
    assert_equal 'test-headline', article.slug
  end

  should "validate slug format on save" do
    article = Article.create!(:headline => 'Test Headline')
    article.slug = 'A BAD $LUG.'

    assert !article.valid?
    assert article.errors[:slug].present?
  end
  
  should "validate uniqueness of slug by default" do
    article1 = Article.create!(:headline => 'Test Headline')
    article2 = Article.create!(:headline => 'Test Headline')
    article2.slug = 'test-headline'
    
    assert !article2.valid?
    assert article2.errors[:slug].present?
  end

  should "use validate_uniquness_if proc to decide whether uniqueness validation applies" do
    article1 = Post.create!(:headline => 'Test Headline')
    article2 = Post.new
    article2.slug = 'test-headline'
    
    assert article2.valid?
  end

  should "not overwrite slug value on create if it was already specified" do
    a = Article.create!(:headline => 'Test Headline', :slug => 'slug1')
    assert_equal 'slug1', a.slug
  end

  context "resetting a slug" do
  
    setup do
      @article = Article.create(:headline => 'test headline')
      @original_slug = @article.slug
    end
    
    should "maintain the same slug if slug column hasn't changed" do
      @article.reset_slug
      assert_equal @original_slug, @article.slug      
    end
    
    should "change slug if slug column has updated" do
      @article.headline = "donkey"
      @article.reset_slug
      assert_not_equal @original_slug, @article.slug
    end
    
    should "maintain sequence" do
      @existing_article = Article.create!(:headline => 'world cup')
      @article.headline = "world cup"
      @article.reset_slug
      assert_equal 'world-cup-1', @article.slug
    end
  
  end
  
  
  context "slug normalization" do
    setup do
      @article = Article.new
    end

    should "should lowercase strings" do
      @article.headline = 'AbC'
      @article.save!
      assert_equal "abc", @article.slug
    end
  
    should "should replace whitespace with dashes" do
      @article.headline = 'a b'
      @article.save!
      assert_equal 'a-b', @article.slug
    end

    should "should replace 2spaces with 1dash" do
      @article.headline = 'a  b'
      @article.save!
      assert_equal 'a-b', @article.slug
    end

    should "should remove punctuation" do
      @article.headline = 'abc!@#$%^&*•¶§∞¢££¡¿()><?""\':;][]\.,/'
      @article.save!
      assert_match 'abc', @article.slug
    end
  
    should "should strip trailing space" do
      @article.headline = 'ab '
      @article.save!
      assert_equal 'ab', @article.slug
    end

    should "should strip leading space" do
      @article.headline = ' ab'
      @article.save!
      assert_equal 'ab', @article.slug
    end
      
    should "should strip trailing dashes" do
      @article.headline = 'ab-'
      @article.save!
      assert_match 'ab', @article.slug
    end

    should "should strip leading dashes" do
      @article.headline = '-ab'
      @article.save!
      assert_match 'ab', @article.slug
    end

    should "remove double-dashes" do
      @article.headline = 'a--b--c'
      @article.save!
      assert_match 'a-b-c', @article.slug
    end

    should "should not modify valid slug strings" do
      @article.headline = 'a-b-c-d'
      @article.save!
      assert_match 'a-b-c-d', @article.slug
    end
    
    should "not insert dashes for periods in acronyms, regardless of where they appear in string" do
      @article.headline = "N.Y.P.D. vs. N.S.A. vs. F.B.I."
      @article.save!
      assert_match 'nypd-vs-nsa-vs-fbi', @article.slug
    end
    
    should "not insert dashes for apostrophes" do
      @article.headline = "Thomas Jefferson's Papers"
      @article.save!
      assert_match 'thomas-jeffersons-papers', @article.slug
    end
    
    should "preserve numbers in slug" do
      @article.headline = "2010 Election"
      @article.save!
      assert_match '2010-election', @article.slug
    end
  end
  
  context "diacritics handling" do
    setup do
      @article = Article.new
    end
  
    should "should strip diacritics" do
      @article.headline = "açaí"
      @article.save!
      assert_equal "acai", @article.slug
    end
  
    should "strip diacritics correctly " do
      @article.headline  = "ÀÁÂÃÄÅÆÇÈÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ"
      @article.save!
      expected = "aaaaaaaeceeeiiiidnoooooouuuuythssaaaaaaaeceeeeiiiidnoooooouuuuythy".split(//)
      output = @article.slug.split(//)
      output.each_index do |i|
        assert_equal expected[i], output[i]
      end
    end
  end

  context "sequence handling" do
    should "not add a sequence if saving first instance of slug" do
      article = Article.create!(:headline => 'Test Headline')
      assert_equal 'test-headline', article.slug
    end
    
    should "assign a -1 suffix to the second instance of the slug" do
      article_1 = Article.create!(:headline => 'Test Headline')
      article_2 = Article.create!(:headline => 'Test Headline')
      assert_equal 'test-headline-1', article_2.slug
    end
    
    should "assign a -12 suffix to the thirteenth instance of the slug" do
      12.times { |i| Article.create!(:headline => 'Test Headline') }
      article_13 = Article.create!(:headline => 'Test Headline')
      assert_equal 'test-headline-12', article_13.slug
    end
  end

end