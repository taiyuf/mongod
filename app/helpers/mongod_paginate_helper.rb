module MongodPaginateHelper

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
    array   = []
    divider = '<li class="disabled"><span aria-hidden="true">..</span></li>'
    wide    = 3
    left    = obj.current_page.to_i - wide.to_i
    right   = obj.current_page.to_i + wide.to_i
    first   = 2
    last    = obj.total_pages.to_i - 1

    # first element
    array.push(make_li_selector_from_params(url, params, 1))

    # left divider
    if left > 1
      array.push(divider)
      first = left + 1
    end

    if right < obj.total_pages.to_i
      last = right - 1
    end

    (first.to_i .. last.to_i).each do |n|
      if obj.current_page.to_i == n.to_i
        array.push("<li class='active'><a href='#'>#{n} <span class='sr-only'>(current)</span></a></li>")
      else
        array.push(make_li_selector_from_params(url, params, n))
      end
    end

    # right divider
    if obj.total_pages.to_i > obj.current_page.to_i + wide.to_i
      array.push(divider)
    end

    # last element
    array.push(make_li_selector_from_params(url, params, obj.total_pages))
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
