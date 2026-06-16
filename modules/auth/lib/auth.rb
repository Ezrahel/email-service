require "auth/engine"

module Auth
  # Handles authentication, authorization, and API key management.
  #
  # Responsibilities:
  # - API key generation and validation
  # - JWT token management (access + refresh)
  # - RBAC (Role-Based Access Control)
  # - IP allowlists
  # - Account lockout
  # - Session management
end
