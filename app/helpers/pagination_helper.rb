module PaginationHelper

  # Helper method to output Zurb Foundation compatible pagination.
  def foundation_paginate(pages, options = {})
    will_paginate(pages, options.reverse_merge({
       class: 'pagination',
       inner_window: 2,
       outer_window: 0,
       renderer: PaginationHelper::FoundationPaginationListLinkRenderer,
       previous_label: '&laquo;'.html_safe,
       next_label: '&raquo;'.html_safe
    }))
  end

  # Override the will_paginate link renderer to create
  # markup that fits the Zurb Foundation pagination components
  # http://thewebfellas.com/blog/2010/8/22/revisited-roll-your-own-pagination-links-with-will_paginate-and-rails-3
  class FoundationPaginationListLinkRenderer < WillPaginate::ActionView::LinkRenderer

    protected

      def gap
        tag :li, link(super, '#'), class: 'unavailable'
      end

      def page_number(page)
        tag :li, link(page, page, rel: rel_value(page)), class: ('current' if page == current_page)
      end

      def previous_or_next_page(page, text, classname)
        tag :li, link(text, page || '#'), class: [classname[0..3], classname, ('unavailable' unless page)].join(' ')
      end

      def html_container(html)
        tag(:ul, html, container_attributes)
      end

      def gap
        tag :li, link(super, '#'), class: 'unavailable'
      end
  end
end
