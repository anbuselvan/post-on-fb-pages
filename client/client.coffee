Meteor.subscribe "notifications"
Session.set "page_id", ""

# Facebook SDK permissions
Accounts.ui.config requestPermissions:
  facebook: [
    "email"
    "user_events"
    "user_status"
    "manage_pages"
    "publish_actions"
  ]

# Retrieve page feed from server
getPageFeed = ->
  pageId = Session.get "page_id"
  if pageId
    Meteor.call "getPageFeed", pageId, (err, result) ->
      if err
        console.log err
      else
        Session.set "page_feed", result.data.data  if $.isArray(result.data.data)  if result.data and result.data.data
      return
  return

# Template to retrieve page feed from server
Template.fb_page_feed.helpers
  feed: ->
    getPageFeed()
    Session.get "page_feed"

  lastUpdated: ->
    user = Meteor.user()
    pageId = Session.get("page_id")
    if user and pageId
      note = Notifications.findOne(user._id)
      if note and note.lastUpdated
        Session.set "last_updated", note.lastUpdated.toISOString()
        getPageFeed()
    Session.get "last_updated"

# Handle events on feed page like refresh feed
Template.fb_page_feed.events
  "click button.refresh": (e, t) ->
    getPageFeed()
    return

  "change select": (e, t) ->
    field = $(e.target)
    mins = field.val()
    pageId = Session.get("page_id")
    if pageId
      Meteor.call "updateFeedPollingInterval", pageId, mins, (err, result) ->
        console.log err  if err
        console.log result
        return
    return

# Template to retrieve and display list of facebook pages on nav menu
Template.fb_pages.helpers
  pages: ->
    unless Session.get "pages"
      Meteor.call "getPages", (err, result) ->
        console.log err  if err
        Session.set "pages", result.data.data  if $.isArray(result.data.data)  if result and result.data and result.data.data
        return
    Session.get "pages"
  isFirst: (value) ->
    value is 0

# Template to retrieve and display facebook profile picture
Template.fb_pic.helpers pic: ->
  unless Session.get("pic")
    Meteor.call "getProfilePic", (err, result) ->
      if err
        console.log err
      else
        Session.set "pic", result.data.picture.data.url  if result and result.data and result.data.picture and result.data.picture.data and result.data.picture.data.url
      return
  Session.get "pic"

# Handle events on each feed like add new comment
Template.fb_page_feed_item.events "click button.add": (e, t) ->
  panel = $(e.target).closest(".panel-default")
  field = panel.find("#comment")
  feedId = field.attr("data-id")
  msg = field.val()
  if feedId isnt "" and msg isnt ""
    Meteor.call "postComment", feedId, msg, (err, result) ->
      console.log err  if err
      if result and result.statusCode is 200
        field.val ""
        getPageFeed()
      return
  return

