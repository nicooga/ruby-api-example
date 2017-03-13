require 'mail'

# Optionally use your own gmail to send email in development
# You may need to disable some security settings on your account to use this.
if RACK_ENV == 'development' && ENV.values_at('GMAIL_USER', 'GMAIL_PASSWORD').all?
  Mail.defaults do
    delivery_method :smtp,
      address:              'smtp.gmail.com',
      port:                 587,
      user_name:            ENV.fetch('GMAIL_USER'),
      password:             ENV.fetch('GMAIL_PASSWORD'),
      authentication:       :plain,
      enable_starttls_auto: true
  end
elsif RACK_ENV != 'test'
  Mail.defaults do
    delivery_method :smtp,
      address:              EMAIL_URL,
      port:                 587,
      authentication:       :plain,
      enable_starttls_auto: true
  end
end
