module PagesHelper
  def connect_button_class provider
    if current_user && current_user.authentications.find_by(provider: provider)
      "disabled"
    else
      ""
    end
  end
end
