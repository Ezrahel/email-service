class ProviderRouter
  ProviderSelection = Struct.new(:provider_config, :provider_type, keyword_init: true)

  class << self
    def select_provider(organization:, email: nil)
      configs = organization.provider_configs.active.healthy.by_priority

      return nil if configs.empty?

      # Weighted random selection among top-priority configs
      top_priority = configs.first.priority
      candidates = configs.select { |c| c.priority == top_priority }

      if candidates.size == 1
        ProviderSelection.new(
          provider_config: candidates.first,
          provider_type: candidates.first.provider_type
        )
      else
        select_weighted(candidates)
      end
    end

    def select_failover(organization:, failed_provider:)
      configs = organization.provider_configs.active.healthy.by_priority
        .reject { |c| c.provider_type == failed_provider }

      return nil if configs.empty?

      ProviderSelection.new(
        provider_config: configs.first,
        provider_type: configs.first.provider_type
      )
    end

    private

    def select_weighted(candidates)
      total_weight = candidates.sum(&:weight)
      return candidates.first if total_weight <= 0

      roll = rand(1..total_weight)
      cumulative = 0

      candidates.each do |candidate|
        cumulative += candidate.weight
        return ProviderSelection.new(provider_config: candidate, provider_type: candidate.provider_type) if roll <= cumulative
      end

      ProviderSelection.new(
        provider_config: candidates.first,
        provider_type: candidates.first.provider_type
      )
    end
  end
end
