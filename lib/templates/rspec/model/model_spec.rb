require 'models/shared_examples'

<% module_namespacing do -%>
RSpec.describe <%= class_name %>, <%= type_metatag(:model) %> do
  include_standard_examples
end
<% end -%>
