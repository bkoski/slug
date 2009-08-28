module Slug
  module ClassMethods
    def slug source, opts={}
      class_inheritable_accessor :slug_source, :slug_column
    
      self.slug_source = source
      self.slug_column = opts.has_key?(:column) ? opts[:column] : :slug
      
      validates_presence_of self.slug_column
      validates_uniqueness_of self.slug_column
      before_validation_on_create :set_slug 
    end
  end
  
  def set_slug
    self[self.slug_column] = self[self.slug_source]

    strip_diacritics_from_slug
    normalize_slug
    assign_slug_sequence
  end
  
  def to_param
    self[self.slug_column]
  end
  
  def self.included(klass)
    klass.extend(ClassMethods)
  end
  
  private
  def normalize_slug
    s = ActiveSupport::Multibyte.proxy_class.new(self[self.slug_column]).normalize(:kc)
    s.strip!
    s.gsub!(/[\W]/u, ' ')
    s.gsub!(/\s+/u, '-')
    s.gsub!(/-\z/u, '')
    s.downcase!
    self[self.slug_column] = s.to_s
  end
  
  def strip_diacritics_from_slug
    s = ActiveSupport::Multibyte.proxy_class.new(self[self.slug_column])
    s = s.normalize(:kd).unpack('U*')
    s = s.inject([]) do |a,u|
      if Slug::ASCII_APPROXIMATIONS[u]
        a += Slug::ASCII_APPROXIMATIONS[u].unpack('U*')
      elsif (u < 0x300 || u > 0x036F)
        a << u
      end
      a
    end
    s = s.pack('U*')
    s.gsub!(/[^a-z0-9]+/i, ' ')
    self[self.slug_column] = s.to_s
  end
  
  def assign_slug_sequence
    idx = next_slug_sequence
    self[self.slug_column] = "#{self[self.slug_column]}-#{idx}" if idx > 0
  end
  
  def next_slug_sequence
    last_in_sequence = self.class.find(:first, :conditions => ["#{self.slug_column} LIKE ?", self[self.slug_column] + '%'],
                                         :order => "CAST(REPLACE(#{self.slug_column},'#{self[self.slug_column]}','') AS UNSIGNED)")
    if last_in_sequence.nil?
      return 0
    else
      sequence_match = last_in_sequence[self.slug_column].match(/^#{self[self.slug_column]}(-(\d+))?/)
      current = sequence_match.nil? ? 0 : sequence_match[2].to_i
      return current + 1
    end
  end
  
end