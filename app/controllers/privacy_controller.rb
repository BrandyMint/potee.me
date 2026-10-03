# What Potee stores and passes on: board data, account, visit attribution,
# Yandex Metrika and the language model behind the plan from text.
class PrivacyController < ApplicationController
  include CurrentUser

  layout "auth"

  def show; end
end
