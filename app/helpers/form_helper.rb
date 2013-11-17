module FormHelper

  def self.included(base)
    ActionView::Base.default_form_builder = Rw2FormBuilder
  end

  class Rw2FormBuilder < ActionView::Helpers::FormBuilder

    # Creates a field wrapped by a div.
    # When called without a block it wraps the block contents -
    # otherwise it defaults to creating an text input for [key] attribute
    # other types can be had by passing a type params into the options hash
    #
    # ex: div_field_with_label(email, type: :email)
    # See @@type_to_method for available types
    #
    # The options hash is passed to the FormHelper method, which means you can
    # pass attributes as if you where calling ex. form.email_field directly.
    #
    # If the field has errors a "warning" class will be added to the <div> wrapper
    # Additionally the errors will be output in a paragraph after the input
    #
    # @param [symbol] key
    # @param [hash] options
    # @param [proc] block
    def div_field_with_label(key, options = {}, &block)

      options = HashWithIndifferentAccess.new(options)
      # start building HTML fragment
      @doc = Nokogiri::HTML::DocumentFragment.parse ""
      Nokogiri::HTML::Builder.with(@doc) do |doc|
        doc.div(class: "field #{key}")
      end
      div = @doc.at_css "div.field"
      div.add_child(Nokogiri::HTML::DocumentFragment.parse(
                        self.label(key, options[:label] ? options[:label].html_safe : nil), @doc)
      )
      if block_given?
        div.add_child(Nokogiri::HTML::DocumentFragment.parse block.call(key), @doc)

      else
        options[:type] ||= :text
        method = self.method(@@type_to_method[options[:type]])
        input = method.call(key, options)
        div.add_child(Nokogiri::HTML::DocumentFragment.parse input, @doc)
      end

      if @object.errors[key].size != 0
        div['class'] = div['class'] << 'warning'
        p = Nokogiri::XML::Node.new "p", @doc
        p.content = @object.errors.full_message(
            object.class.human_attribute_name(key).capitalize,
            @object.errors[key].join(', ')
        )
        p['class'] = "error-message warning alert"
        div.add_child(p)
      end

      @doc.to_html.html_safe

    end

    @@type_to_method = HashWithIndifferentAccess.new ({
        check_box: :check_box,
        color: :color_field,
        date: :date_field,
        datetime: :datetime_field,
        datetime_local: :datetime_local_field,
        email: :email_field,
        file: :file_field,
        month: :month_field,
        number: :number_field,
        password: :password_field,
        phone_field: :phone_field,
        radio_button: :radio_button,
        range_field: :range_field,
        search: :search_field,
        telephone: :telephone_field,
        text_area: :text_area,
        text: :text_field,
        time: :time_field,
        url: :url_field,
        week: :week_field,
    })

  end
end