require_tree 'components'
require_tree 'handlers'
require_tree 'stores'

$document.ready do
  connection = Handlers::Connection.new
  React.render React.create_element(Components::MainComponent, connection: connection), `document.getElementById('content')`
end
