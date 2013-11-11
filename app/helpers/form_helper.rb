module FormHelper

  def self.included(base)
    ActionView::Base.default_form_builder = Rw2FormBuilder
  end

  class Rw2FormBuilder < ActionView::Helpers::FormBuilder

    # @param [symbol] key
    # @param [proc] block
    def div_field_with_label(key, txt = nil, &block)

      content = self.label(key, txt ? txt.html_safe : nil)

      if block_given?
        content << block.call(key)
      end
      classes = ['field']
      classes << key.to_s
      if @object.errors[key].size != 0
        classes << 'warning'
        msg = @object.errors.full_message(key, @object.errors[key].join(', '))
        content << @template.content_tag(:p, msg, :class => "error-message warning alert" )
      end

      @template.content_tag(:div, content, :class => classes.join(' ').html_safe)
    end
  end
end