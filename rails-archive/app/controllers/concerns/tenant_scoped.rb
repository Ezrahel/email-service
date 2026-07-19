module TenantScoped
  extend ActiveSupport::Concern

  included do
    default_scope lambda {
      if Current.organization_id
        where(organization_id: Current.organization_id)
      end
    }

    before_validation :set_organization, on: :create, if: :has_organization_id?
  end

  class_methods do
    def unscoped_for(organization)
      unscoped.where(organization_id: organization.id)
    end
  end

  private

  def has_organization_id?
    respond_to?(:organization_id=)
  end

  def set_organization
    self.organization_id ||= Current.organization_id
  end
end
