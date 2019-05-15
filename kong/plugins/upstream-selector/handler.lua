local BasePlugin = require "kong.plugins.base_plugin"

local UpstreamSelectorHandler = BasePlugin:extend()

UpstreamSelectorHandler.PRIORITY = 2000

function UpstreamSelectorHandler:new()
  UpstreamSelectorHandler.super.new(self, "upstream-selector")
end

function UpstreamSelectorHandler:access(conf)
  UpstreamSelectorHandler.super.access(self)

  if conf.say_hello then
    kong.log.debug('Hey!')

    kong.service.request.set_header('X-Upstream-Header', 'Hey Upstream!')
    kong.response.set_header('X-Downstream-Header', 'Hey Downstream!')
  else
    kong.log.debug('Bye!')

    kong.service.request.set_header('X-Upstream-Header', 'Bye Upstream!')
    kong.response.set_header('X-Downstream-Header', 'Bye Downstream!')
  end

end

return UpstreamSelectorHandler
