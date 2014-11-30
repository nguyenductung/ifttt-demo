module ApplicationHelper
  def connect_button_class provider
    if current_user && current_user.authentications.find_by(provider: provider)
      "disabled"
    else
      ""
    end
  end

  def enable_button_class m_recipe
    classes = []
    [m_recipe.source, m_recipe.target].each do |provider|
      if provider.in? %w( twitter instagram google )
        classes << "#{provider}-required"
      end
    end
    classes.join(" ")
  end
end
