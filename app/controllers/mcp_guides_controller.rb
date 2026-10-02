# The page a browser gets at /mcp: how to connect an agent and which tools the
# server offers, read from the same definitions that tools/list returns.
class McpGuidesController < ApplicationController
  include CurrentUser

  layout "auth"

  def show
    @instructions = McpController::INSTRUCTIONS
    @tools = Mcp::Tools::DEFINITIONS
  end
end
