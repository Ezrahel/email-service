/**
 * Application error hierarchy with standardized error codes
 * All errors extend ApplicationError for consistent handling
 */

export interface ErrorDetails {
  readonly [key: string]: unknown;
}

export interface ApplicationErrorOptions {
  readonly code?: string;
  readonly status?: number;
  readonly details?: ErrorDetails;
  readonly cause?: Error;
}

export abstract class ApplicationError extends Error {
  public readonly code: string;
  public readonly status: number;
  public readonly details: ErrorDetails;
  public override readonly cause?: Error;
  public readonly timestamp: Date;

  constructor(message: string, options: ApplicationErrorOptions = {}) {
    super(message);
    this.name = this.constructor.name;
    this.code = options.code ?? this.constructor.name.replace("Error", "").toUpperCase();
    this.status = options.status ?? 500;
    this.details = options.details ?? {};
    this.cause = options.cause;
    this.timestamp = new Date();

    Error.captureStackTrace(this, this.constructor);
  }

  public toJSON(): Record<string, unknown> {
    return {
      name: this.name,
      message: this.message,
      code: this.code,
      status: this.status,
      details: this.details,
      timestamp: this.timestamp.toISOString(),
    };
  }

  public toResponse(): { error: { code: string; message: string; details?: ErrorDetails } } {
    return {
      error: {
        code: this.code,
        message: this.message,
        ...(Object.keys(this.details).length > 0 && { details: this.details }),
      },
    };
  }
}

// 4xx Client Errors

export class ValidationError extends ApplicationError {
  constructor(message: string = "Validation failed", details: ErrorDetails = {}) {
    super(message, { code: "VALIDATION_ERROR", status: 422, details });
  }
}

export class NotFoundError extends ApplicationError {
  constructor(resource: string, identifier?: string) {
    const message = identifier ? `${resource} not found: ${identifier}` : `${resource} not found`;
    super(message, { code: "NOT_FOUND", status: 404, details: { resource, identifier } });
  }
}

export class UnauthorizedError extends ApplicationError {
  constructor(message: string = "Authentication required", details: ErrorDetails = {}) {
    super(message, { code: "UNAUTHORIZED", status: 401, details });
  }
}

export class ForbiddenError extends ApplicationError {
  constructor(message: string = "Access denied", details: ErrorDetails = {}) {
    super(message, { code: "FORBIDDEN", status: 403, details });
  }
}

export class ConflictError extends ApplicationError {
  constructor(message: string, details: ErrorDetails = {}) {
    super(message, { code: "CONFLICT", status: 409, details });
  }
}

export class RateLimitError extends ApplicationError {
  public readonly retryAfter: number;

  constructor(message: string = "Rate limit exceeded", retryAfter: number, details: ErrorDetails = {}) {
    super(message, { code: "RATE_LIMIT_EXCEEDED", status: 429, details: { ...details, retryAfter } });
    this.retryAfter = retryAfter;
  }
}

export class IdempotencyError extends ApplicationError {
  constructor(idempotencyKey: string, details: ErrorDetails = {}) {
    super(`Idempotency key already used: ${idempotencyKey}`, {
      code: "IDEMPOTENCY_CONFLICT",
      status: 409,
      details: { ...details, idempotencyKey },
    });
  }
}

export class QuotaExceededError extends ApplicationError {
  constructor(quotaType: string, limit: number, details: ErrorDetails = {}) {
    super(`${quotaType} quota exceeded: ${limit}`, {
      code: "QUOTA_EXCEEDED",
      status: 429,
      details: { ...details, quotaType, limit },
    });
  }
}

// 5xx Server Errors

export class InternalError extends ApplicationError {
  constructor(message: string = "Internal server error", details: ErrorDetails = {}) {
    super(message, { code: "INTERNAL_ERROR", status: 500, details });
  }
}

export class ProviderError extends ApplicationError {
  public readonly provider: string;
  public readonly providerCode?: string;

  constructor(provider: string, message: string, providerCode?: string, details: ErrorDetails = {}) {
    super(`Provider ${provider} error: ${message}`, {
      code: "PROVIDER_ERROR",
      status: 502,
      details: { ...details, provider, providerCode },
    });
    this.provider = provider;
    this.providerCode = providerCode;
  }
}

export class ProviderUnavailableError extends ApplicationError {
  constructor(provider: string, details: ErrorDetails = {}) {
    super(`Provider ${provider} is currently unavailable`, {
      code: "PROVIDER_UNAVAILABLE",
      status: 503,
      details: { ...details, provider },
    });
  }
}

export class ConfigurationError extends ApplicationError {
  constructor(message: string, details: ErrorDetails = {}) {
    super(message, { code: "CONFIGURATION_ERROR", status: 500, details });
  }
}

export class ExternalServiceError extends ApplicationError {
  public readonly service: string;
  public readonly statusCode?: number;

  constructor(service: string, message: string, statusCode?: number, details: ErrorDetails = {}) {
    super(`External service ${service} error: ${message}`, {
      code: "EXTERNAL_SERVICE_ERROR",
      status: (statusCode ?? 0) >= 500 ? 502 : 500,
      details: { ...details, service, statusCode },
    });
    this.service = service;
    this.statusCode = statusCode;
  }
}

export class TimeoutError extends ApplicationError {
  public readonly operation: string;
  public readonly timeout: number;

  constructor(operation: string, timeout: number, details: ErrorDetails = {}) {
    super(`Operation timed out: ${operation} (${timeout}ms)`, {
      code: "TIMEOUT",
      status: 504,
      details: { ...details, operation, timeout },
    });
    this.operation = operation;
    this.timeout = timeout;
  }
}

export class CircuitOpenError extends ApplicationError {
  public readonly circuit: string;

  constructor(circuit: string, details: ErrorDetails = {}) {
    super(`Circuit breaker open: ${circuit}`, {
      code: "CIRCUIT_OPEN",
      status: 503,
      details: { ...details, circuit },
    });
    this.circuit = circuit;
  }
}

/**
 * Error code mapping for quick lookup
 */
export const ERROR_CODES = {
  VALIDATION_ERROR: "VALIDATION_ERROR",
  NOT_FOUND: "NOT_FOUND",
  UNAUTHORIZED: "UNAUTHORIZED",
  FORBIDDEN: "FORBIDDEN",
  CONFLICT: "CONFLICT",
  RATE_LIMIT_EXCEEDED: "RATE_LIMIT_EXCEEDED",
  IDEMPOTENCY_CONFLICT: "IDEMPOTENCY_CONFLICT",
  QUOTA_EXCEEDED: "QUOTA_EXCEEDED",
  INTERNAL_ERROR: "INTERNAL_ERROR",
  PROVIDER_ERROR: "PROVIDER_ERROR",
  PROVIDER_UNAVAILABLE: "PROVIDER_UNAVAILABLE",
  CONFIGURATION_ERROR: "CONFIGURATION_ERROR",
  EXTERNAL_SERVICE_ERROR: "EXTERNAL_SERVICE_ERROR",
  TIMEOUT: "TIMEOUT",
  CIRCUIT_OPEN: "CIRCUIT_OPEN",
} as const;

export type ErrorCode = (typeof ERROR_CODES)[keyof typeof ERROR_CODES];

/**
 * Map HTTP status to error class
 */
export function errorClassForStatus(status: number): new (...args: any[]) => ApplicationError {
  const mapping: Record<number, new (...args: any[]) => ApplicationError> = {
    400: ValidationError,
    401: UnauthorizedError,
    403: ForbiddenError,
    404: NotFoundError,
    409: ConflictError,
    422: ValidationError,
    429: RateLimitError,
    500: InternalError,
    502: ProviderError,
    503: ProviderUnavailableError,
    504: TimeoutError,
  };
  return mapping[status] ?? InternalError;
}

/**
 * Create error from unknown value
 */
export function toApplicationError(error: unknown): ApplicationError {
  if (error instanceof ApplicationError) return error;
  if (error instanceof Error) {
    return new InternalError(error.message, { cause: error });
  }
  return new InternalError("Unknown error", { details: { original: error } });
}

/**
 * Check if error is retryable
 */
export function isRetryableError(error: unknown): boolean {
  if (error instanceof ApplicationError) {
    const nonRetryableCodes = new Set([
      "VALIDATION_ERROR",
      "NOT_FOUND",
      "UNAUTHORIZED",
      "FORBIDDEN",
      "CONFLICT",
      "QUOTA_EXCEEDED",
      "IDEMPOTENCY_CONFLICT",
      "CONFIGURATION_ERROR",
    ]);
    return !nonRetryableCodes.has(error.code);
  }
  return true;
}