require 'mongod'

module MongodPaginationHelper

  def next_page_class(obj)
    obj.current_page.to_i == obj.total_pages ? ' class="disabled"' : ''
  end

  def previous_page_class(obj)
    obj.current_page.to_i == 1 ? ' class="disabled"' : ''
  end

  def next_page_link(obj, url, params)
    if obj.current_page.to_i == obj.total_pages
      '#'
    else
      array = make_array_from_params(params)
      array.push("page=#{obj.next_page.to_i}")
      "#{url}?#{array.join('&').to_s}"
    end
  end

  def previous_page_link(obj, url, params)
    if obj.current_page.to_i == 1
      '#'
    else
      array = make_array_from_params(params)
      array.push("page=#{obj.previous_page.to_i}")
      "#{url}?#{array.join('&').to_s}"
    end
  end

  def paginate_link(obj, url, params)
    array         = []
    divider       = %q{<li class="disabled"><span aria-hidden="true">..</span></li>}
    wide          = Mongod::PAGINATION_WIDE.to_i
    current       = obj.current_page.to_i
    total         = obj.total_pages.to_i
    first         = 2
    last          = total - 1
    right_divider = false
    left_divider  = false

    if total <= wide * 2
      # less than 6
      left  = 2
      # 1, *_2_*, 3, _4_, 5 #=> p1
      # 1, _2_, 3, *_4_*, 5 #=> p2
      right = total - 1
    else
      # greater than 7
      if current <= wide
        # 1, *_2_*, 3, 4, 5, _6_, .., 9 #=> p3
        # 1, _2_, *3*, 4, 5, _6_, .., 9 #=> p4
        right         = wide * 2
        left          = 2
        right_divider = true
      else
          left_divider = true
        if current + wide > total

          right        = total - 1

          if total - wide + 1 < current
            # 1, .., _4_, 5, 6, 7, *_8_*, 9 #=> p5
            left = total - wide * 2 + 1
          else
            # 1, .., _4_, 5, 6, *7*, _8_, 9 #=> p6
            left = current - wide
          end
        else
        # 1, .., _3_, 4, *5*, 6, _7_, .., 9 #=> p7
          right_divider = true
          left          = current - wide + 1
          right         = current + wide - 1
        end
      end

    end

    # first element
    if current == 1
      array.push("<li class='active'><a href='#'>1 <span class='sr-only'>(current)</span></a></li>")
    else
      array.push(make_li_selector_from_params(url, params, 1))
    end

    # left divider
    array.push(divider) if left_divider

    (left.to_i .. right.to_i).each do |n|
      if current == n.to_i
        array.push("<li class='active'><a href='#'>#{n} <span class='sr-only'>(current)</span></a></li>")
      else
        array.push(make_li_selector_from_params(url, params, n))
      end
    end

    # right divider
    array.push(divider) if right_divider

    # last element
    unless total == 1
      if current == total
        array.push("<li class='active'><a href='#'>#{total} <span class='sr-only'>(current)</span></a></li>")
      else
        array.push(make_li_selector_from_params(url, params, obj.total_pages))
      end
    end

    array.join("\n").html_safe
  end

  private

  def make_array_from_params(params)
    array = []
    params.each do |k, v|
      array.push("#{k}=#{v}")
    end
    array
  end

  def make_li_selector_from_params(uri, params, page)
    param = make_array_from_params(params)
    param.push("page=#{page.to_i}")
    "<li><a href='#{uri}?#{param.join('&').to_s}'>#{page}</a></li>"
  end

end
