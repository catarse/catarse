module ActionDispatch
  class Request
    # Access the contents of the flash. Use <tt>flash["notice"]</tt> to
    # read a notice you put there or <tt>flash["notice"] = "hello"</tt>
    # to put a new one.
    def flash
      @env['action_dispatch.request.flash_hash'] ||= (session["flash"] || Flash::FlashHash.new)
    end
  end
end

