class FeedbackForm < MailForm::Base
  attribute :email,     validate: Devise.email_regexp

  attribute :message

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      subject: "Online Feedback Form",
      to: CatarseSettings[:email_contact],
      from: email
    }
  end
end
