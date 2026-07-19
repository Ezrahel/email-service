module Domains
  class VerifyDomain < ApplicationService
    attr_reader :domain, :checks

    def initialize(domain:)
      @domain = domain
      @checks = {}
    end

    def call
      @domain.update!(status: "verifying")

      @domain.dns_records.each do |record|
        @checks[record.record_type] = record.verify!
      end

      all_verified = @checks.values.all?
      @domain.update!(
        is_verified: all_verified,
        verified_at: all_verified ? Time.current : nil,
        status: all_verified ? "verified" : "failed"
      )

      self
    end
  end
end
