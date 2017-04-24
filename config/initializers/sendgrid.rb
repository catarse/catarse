begin
  if Rails.env.production?
    ActionMailer::Base.smtp_settings = {
      address: 'smtp.sendgrid.net',
      port: CatarseSettings.get_without_cache(:sendgrid_port),
      authentication: :plain,
      user_name: "myjvnepal",
      password: "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",
      domain: 'myjvn.com'
    }
    ActionMailer::Base.delivery_method = :smtp
  end
rescue
  nil
end

if Rails.env.sandbox?
  ActionMailer::Base.register_interceptor(SandboxMailInterceptor)
end
