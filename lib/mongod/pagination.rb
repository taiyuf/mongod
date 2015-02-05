# coding: utf-8

module Mongod

  module Pagination
    #
    # require: please set array to the instance valuable, @_result
    #
    attr_accessor *%i{
      per_page
      total_pages
      total_entries
      current_page
    }

    def page=(p=nil)

      if p.nil?
        self.total_pages.to_i
      else
        # ???
        self.current_page = p.to_i
      end
    end

    def paginate(hash={})

      self.page          = hash[:page]
      self.per_page      = hash[:per_page] ? hash[:per_page] : Mongod::PAGINATION_PER_PAGE.to_i
      self.total_entries = @_result.count.to_i
      @_result           = @_result
                           .drop(self.per_page.to_i * (self.current_page.to_i - 1))
                           .first(self.per_page.to_i)

      div                = self.total_entries.divmod(self.per_page.to_i)
      self.total_pages   = div[1] == 0 ? div[0].to_i : div[0].to_i + 1

      self
    end

    def count
      @_result.count.to_i
    end

    def next_page
      self.current_page.to_i == self.total_pages.to_i ? nil : self.current_page.to_i + 1
    end

    def previous_page
      self.current_page.to_i == 1 ? nil : self.current_page.to_i - 1
    end

    def first_page
      1.to_i
    end

    alias_method :last_page, :total_pages
  end

end
