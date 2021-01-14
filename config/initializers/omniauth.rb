require "omniauth/strategies/france_connect"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV["GITHUB_APP_ID"], ENV["GITHUB_APP_SECRET"], scope: "user:email"

  provider(
    :france_connect,
    name: :france_connect,
    scope: [:email, :openid, :birthdate, :birthplace, :given_name, :family_name, :birthcountry],
    issuer: "https://#{ENV['FRANCE_CONNECT_HOST']}",
    client_options: {
      identifier: ENV["FRANCE_CONNECT_APP_ID"],
      secret: ENV["FRANCE_CONNECT_APP_SECRET"],
      redirect_uri: "#{ENV['HOST']}/omniauth/france_connect/callback",
      host: ENV["FRANCE_CONNECT_HOST"]
    }
  )

  on_failure do |env|
    env["devise.mapping"] = Devise.mappings[:user]
    SuperAdmins::OmniauthCallbacksController.action(:failure).call(env)
  end
end
