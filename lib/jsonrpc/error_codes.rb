
module Jsonrpc
  module ErrorCodes

    INVALID_JSON = -32700
    INVALID_REQUEST = -32600
    METHOD_NOT_FOUND = -32601
    INVALID_PARAMETERS = -32602
    INTERNAL_ERROR = -32603

    # implementation-defined server-errors:
    # These error-codes can be used for JSON-RPC 2.0 servers/frameworks/libraries for their own errors (e.g. if the JSON-RPC-server itself fails).
    RESEVERED_ERRORS = (-32099..-32000)

    # Errors which cannot freely be used by procedures which are called via JSON-RPC.
    NON_APPLICATION_ERRORS = (-32000..-32768)

  end
end

