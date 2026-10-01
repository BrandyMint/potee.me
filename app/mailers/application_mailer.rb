class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "Potee <no-reply@potee.pismenny.ru>")
  layout "mailer"
end
