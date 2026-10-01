# MCP server (Model Context Protocol, Streamable HTTP transport without SSE):
# AI agents read and change the user's board with JSON-RPC calls to POST /mcp,
# authenticated by the personal token from /account (Authorization: Bearer).
class McpController < ActionController::API
  PROTOCOL_VERSIONS = %w[2025-06-18 2025-03-26 2024-11-05].freeze
  INSTRUCTIONS = <<~TEXT.squish.freeze
    Potee is a visual project planner: each project is a bar on a timeline from start_date to end_date
    (inclusive), and milestones (events) are marks on it. Call list_projects first to see the board and ids.
    Dates are YYYY-MM-DD, times HH:MM in Europe/Moscow unless a timezone is given. Milestones must stay within
    their project's dates. Deleting a project the user owns deletes it for everyone it is shared with.
  TEXT

  before_action :authenticate

  def handle
    payload = JSON.parse(request.raw_post.presence || "null")
    return render(json: rpc_error(nil, -32600, "Batch requests are not supported"), status: :bad_request) if payload.is_a?(Array)
    return render(json: rpc_error(nil, -32600, "Invalid request"), status: :bad_request) unless payload.is_a?(Hash)

    message = payload.with_indifferent_access
    return head(:accepted) unless message.key?(:id) # notifications need no response

    render json: rpc_response(message)
  rescue JSON::ParserError
    render json: rpc_error(nil, -32700, "Parse error"), status: :bad_request
  end

  # No server-initiated stream: clients must use POST.
  def stream
    head :method_not_allowed
  end

  private

  def authenticate
    token = request.authorization.to_s.delete_prefix("Bearer ").strip
    @user = User.find_by_api_token(token)
    return if @user

    response.headers["WWW-Authenticate"] = 'Bearer realm="potee"'
    render json: rpc_error(nil, -32001, "Missing or invalid token: create one at #{account_url}"), status: :unauthorized
  end

  def rpc_response(message)
    id = message[:id]
    params = message[:params] || {}
    case message[:method]
    when "initialize" then rpc_result(id, initialize_result(params[:protocolVersion]))
    when "ping" then rpc_result(id, {})
    when "tools/list" then rpc_result(id, { tools: tools.definitions })
    when "tools/call" then rpc_result(id, call_tool(params[:name], params[:arguments]))
    else rpc_error(id, -32601, "Method not found: #{message[:method]}")
    end
  end

  def initialize_result(requested_version)
    {
      protocolVersion: PROTOCOL_VERSIONS.include?(requested_version) ? requested_version : PROTOCOL_VERSIONS.first,
      capabilities: { tools: { listChanged: false } },
      serverInfo: { name: "potee", title: "Potee", version: "1.0" },
      instructions: INSTRUCTIONS
    }
  end

  # Tool failures are results with isError, so the agent can read and recover.
  def call_tool(name, arguments)
    data = tools.call(name.to_s, arguments)
    { content: [ { type: "text", text: JSON.pretty_generate(data) } ], structuredContent: data, isError: false }
  rescue Mcp::Tools::Error, ActiveRecord::RecordInvalid => error
    { content: [ { type: "text", text: error.message } ], isError: true }
  end

  def tools
    @tools ||= Mcp::Tools.new(@user, share_url: ->(key) { share_url(key) })
  end

  def rpc_result(id, result)
    { jsonrpc: "2.0", id:, result: }
  end

  def rpc_error(id, code, message)
    { jsonrpc: "2.0", id:, error: { code:, message: } }
  end
end
