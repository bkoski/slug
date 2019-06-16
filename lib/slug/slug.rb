require 'active_support/concern'

module Slug
  extend ActiveSupport::Concern

  class_methods do

    # Call this to set up slug handling on an ActiveRecord model.
    #
    # Params:
    # * <tt>:source</tt> - the column the slug will be based on (e.g. :<tt>headline</tt>)
    #
    # Options:
    # * <tt>:column</tt> - the column the slug will be saved to (defaults to <tt>:slug</tt>)
    # * <tt>:validate_uniquness_if</tt> - proc to determine whether uniqueness validation runs, same format as validates_uniquness_of :if
    #
    # Slug will take care of validating presence and uniqueness of slug.

    # Before create, Slug will generate and assign the slug if it wasn't explicitly set.
    # Note that subsequent changes to the source column will have no effect on the slug.
    # If you'd like to update the slug later on, call <tt>@model.set_slug</tt>
    def slug source, opts={}
      class_attribute :slug_source, :slug_column, :generic_default

      self.slug_source = source
      self.slug_column = opts.fetch(:column, :slug)
      self.generic_default = opts.fetch(:generic_default, false)

      uniqueness_opts = {}
      uniqueness_opts.merge!(:if => opts[:validate_uniqueness_if]) if opts[:validate_uniqueness_if].present?
      validates_uniqueness_of self.slug_column, uniqueness_opts

      validates_presence_of self.slug_column,
        message: "cannot be blank. Is #{self.slug_source} sluggable?"
      validates_format_of self.slug_column,
        with: /\A[a-z0-9-]+\z/,
        message: "contains invalid characters. Only downcase letters, numbers, and '-' are allowed."
      before_validation :set_slug, :on => :create

      include SlugInstanceMethods
    end
  end

  module SlugInstanceMethods
    # Sets the slug. Called before create.
    # By default, set_slug won't change slug if one already exists.  Pass :force => true to overwrite.
    def set_slug(opts={})
      validate_slug_columns
      return if self[self.slug_column].present? && !opts[:force]

      self[self.slug_column] = normalize_slug(self.send(self.slug_source))

      # if normalize_slug returned a blank string, try the generic_default handling
      if generic_default && self[self.slug_column].blank?
        self[self.slug_column] = self.class.to_s.demodulize.underscore.dasherize
      end

      assign_slug_sequence if self.changed_attributes.include?(self.slug_column)
    end

    # Overwrite existing slug based on current contents of source column.
    def reset_slug
      set_slug(:force => true)
    end

    # Overrides to_param to return the model's slug.
    def to_param
      self[self.slug_column]
    end

    private
    # Validates that source and destination methods exist. Invoked at runtime to allow definition
    # of source/slug methods after <tt>slug</tt> setup in class.
    def validate_slug_columns
      raise ArgumentError, "Source column '#{self.slug_source}' does not exist!" if !self.respond_to?(self.slug_source)
      raise ArgumentError, "Slug column '#{self.slug_column}' does not exist!"   if !self.respond_to?("#{self.slug_column}=")
    end

    # Takes the slug, downcases it and replaces non-word characters with a -.
    # Feel free to override this method if you'd like different slug formatting.
    def normalize_slug(str)
      return if str.blank?
      str.gsub!(/[\p{Pc}\p{Ps}\p{Pe}\p{Pi}\p{Pf}\p{Po}]/, '') # Remove punctuation
      str.parameterize
    end

    # If a slug of the same name already exists, this will append '-n' to the end of the slug to
    # make it unique. The second instance gets a '-1' suffix.
    def assign_slug_sequence
      return if self[self.slug_column].blank?
      assoc = self.class.base_class
      base_slug = self[self.slug_column]
      seq = 0

      while assoc.where(self.slug_column => self[self.slug_column]).exists? do
        seq += 1
        self[self.slug_column] = "#{base_slug}-#{seq}"
      end
    end
  end
end
