class UserMailer < ApplicationMailer
  def account_activation user
    @user = user
    mail to: user.email, subject: t("account_activation.account")
  end

  def password_reset user
    @user = user
    mail to: user.email, subject: t("password_reset.reset_password")
  end
end
