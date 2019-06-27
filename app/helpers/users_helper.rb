module UsersHelper
  def birth_date_and_age(user)
    return unless user.birth_date

    age = l(user.birth_date)
    age += " - #{user.age} ans"
    age
  end

  def add_user_button(btn_style = 'btn-primary')
    link_to 'Ajouter un usager', new_organisation_user_path, class: "btn #{btn_style}", data: { rightbar: true } if policy(User).create?
  end

  def formatted_phone_number(user)
    user.phone_number.chars.each_slice(2).map(&:join).join(' ') unless user.phone_number.blank?
  end
end
