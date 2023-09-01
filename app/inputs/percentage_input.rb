class PercentageInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    original_value = object.public_send(attribute_name)
    percentage_value = original_value ? (original_value * 100).to_i : nil

    input_html = @builder.number_field(attribute_name, merged_input_options.merge(value: percentage_value))
    "#{input_html}%".html_safe
  end
end
