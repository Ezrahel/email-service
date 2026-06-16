module Api
  module V1
    class DomainsController < BaseController
      before_action :require_domain_scope!
      before_action :set_domain, only: %i[show verify destroy]

      def index
        domains = current_organization.domains
          .order(created_at: :desc)
          .then { |scope| params[:verified].present? ? scope.where(is_verified: params[:verified]) : scope }

        records, pagy = paginate(domains)
        render_collection(records, DomainSerializer, meta: pagy_meta(pagy))
      end

      def create
        require_scope!("domain:manage")

        form = CreateDomainForm.new(domain_params.merge(organization: current_organization))

        unless form.valid?
          raise Errors::ValidationError, details: form.errors.messages
        end

        result = Domains::CreateDomain.call(
          organization: current_organization,
          params: form.attributes
        )

        render_success(
          DomainSerializer.new(result.domain).serializable_hash[:data],
          status: :created
        )
      end

      def show
        render_success DomainSerializer.new(@domain).serializable_hash[:data]
      end

      def verify
        require_scope!("domain:manage")

        result = Domains::VerifyDomain.call(domain: @domain)

        render_success(
          DomainSerializer.new(result.domain).serializable_hash[:data],
          meta: { dns_checks: result.checks }
        )
      end

      def destroy
        require_scope!("domain:manage")

        @domain.soft_delete
        render_success(message: "Domain deleted")
      end

      private

      def set_domain
        @domain = current_organization.domains.find(params[:id])
      end

      def domain_params
        params.permit(:domain, :region, :tracking_subdomain)
      end

      def require_domain_scope!
        require_scope!("domain:manage")
      rescue Errors::ForbiddenError
        raise unless action_name.in?(%w[index show])
      end

      def pagy_meta(pagy)
        { page: pagy.page, per_page: pagy.items, total: pagy.count, pages: pagy.pages }
      end
    end
  end
end
