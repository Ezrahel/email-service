module Domains
  class CreateDomain < ApplicationService
    attr_reader :domain

    def initialize(organization:, params:)
      @organization = organization
      @params = params.with_indifferent_access
    end

    def call
      generate_keys!

      @domain = @organization.domains.create!(
        domain: @params[:domain],
        region: @params[:region] || "us",
        status: "pending",
        verification_token: SecureRandom.hex(16),
        dkim_selector: @params[:dkim_selector] || "mailo",
        dkim_private_key: @dkim_private,
        dkim_public_key: @dkim_public,
        tracking_subdomain: @params[:tracking_subdomain] || "track",
        spf_record: generate_spf_record,
        dkim_record: generate_dkim_record,
        dmarc_record: generate_dmarc_record,
        mx_record: generate_mx_record
      )

      @domain.generate_dns_records!

      self
    end

    private

    def generate_keys!
      rsa_key = OpenSSL::PKey::RSA.new(2048)
      @dkim_private = rsa_key.to_pem
      @dkim_public = rsa_key.public_key.to_pem
    rescue StandardError => e
      @dkim_private = nil
      @dkim_public = "placeholder-public-key-#{SecureRandom.hex(8)}"
    end

    def generate_spf_record
      "v=spf1 include:mail.#{@params[:domain]} ~all"
    end

    def generate_dkim_record
      "v=DKIM1; k=rsa; p=#{@dkim_public&.gsub(/-----[A-Z ]+-----/, '')&.gsub("\n", '')}"
    end

    def generate_dmarc_record
      "v=DMARC1; p=none; rua=mailto:dmarc@#{@params[:domain]}"
    end

    def generate_mx_record
      "10 mail.#{@params[:domain]}"
    end
  end
end
