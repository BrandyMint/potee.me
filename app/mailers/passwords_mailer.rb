class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "Reset your Potee password", to: user.email
  end
end
