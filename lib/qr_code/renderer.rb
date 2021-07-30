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

    def self.as_base64_png(string)
      qrcode = RQRCode::QRCode.new(string)
      png = qrcode.as_png(size: 350)
      Base64.strict_encode64 png.to_blob(:fast_rgb)
    end
  end
end
