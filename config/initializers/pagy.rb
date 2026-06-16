require "pagy/extras/overflow"
require "pagy/extras/metadata"

Pagy::DEFAULT[:items] = 50
Pagy::DEFAULT[:max_items] = 100
Pagy::DEFAULT[:overflow] = :last_page
Pagy::DEFAULT[:metadata] = %i[page items count pages prev next]
