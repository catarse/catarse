module AbstractController
  module Rendering
    # Normalize args and options.
    # :api: private
    def _normalize_render(*args, &block)
      options = _normalize_args(*args, &block)
      # TODO: remove defined? when we restore AP <=> AV dependency
      if defined?(request) && request && request.variant.present?
        options[:variant] = request.variant
      end
      _normalize_options(options)
      options
    end
  end
end
