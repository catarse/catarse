class SandboxMailInterceptor
  def self.delivering_email(message)
    message.to = CatarseSettings[:sandbox_emails_redirect].split(",")
  end
end
