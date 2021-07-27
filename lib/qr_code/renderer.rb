# frozen_string_literal: true

require 'rqrcode'
module QRCode
  class Renderer
    def self.as_svg(string)
      qrcode = RQRCode::QRCode.new(string)

      qrcode.as_svg(
        offset: 0,
        color: '000',
        shape_rendering: 'crispEdges',
        module_size: 4,
        standalone: true
      )
    end
  end
end
