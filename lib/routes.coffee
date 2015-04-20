Router.configure
  layoutTemplate: "layout"

Router.route "/", ->
  @render "home"
  return

Router.route "/page/:_id", ->
  Session.set "page_id", @params._id  if @params._id
  Session.set "last_updated", new Date().toISOString()
  @render "fb_page",
    data:
      id: @params._id
  return

