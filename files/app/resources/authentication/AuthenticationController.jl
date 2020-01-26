module AuthenticationController

using Genie, Genie.Renderer, Genie.Renderer.Html, Genie.Router
using ViewHelper
using SearchLight
using GenieAuthentication
using Users
using Logging

function show_login()
  html(:authentication, :login, context = @__MODULE__)
end

function login()
  try
    user = SearchLight.findone(User, username = Genie.Router.@params(:username), password = Users.hash_password(Genie.Router.@params(:password)))
    GenieAuthentication.authenticate(user.id, Genie.Sessions.session(Genie.Router.@params))

    Genie.Renderer.redirect(:get_home)
  catch ex
    Genie.Flash.flash("Authentication failed")

    Genie.Renderer.redirect(:show_login)
  end
end

function logout()
  GenieAuthentication.deauthenticate(Genie.Sessions.session(Genie.Router.@params))

  Genie.Flash.flash("Good bye! ")

  Genie.Renderer.redirect(:show_login)
end

function show_register()
  Genie.Renderer.Html.html(:authentication, :register, context = @__MODULE__)
end

function register()
  try
    user = SearchLight.save!!(User( username  = Genie.Router.@params(:username),
                                    password  = Genie.Router.@params(:password) |> Users.hash_password,
                                    name      = Genie.Router.@params(:name),
                                    email     = Genie.Router.@params(:email)))

    GenieAuthentication.authenticate(user.id, Genie.Sessions.session(Genie.Router.@params))

    "Registration successful"
  catch ex
    Genie.Flash.flash(ex.msg)

    Genie.Renderer.redirect(:show_register)
  end
end

end