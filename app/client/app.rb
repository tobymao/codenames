require_tree 'components'
require_tree 'handlers'
require_tree 'stores'

$document.ready do
  React.render React.create_element(Components::MainComponent), `document.getElementById('content')`
end
