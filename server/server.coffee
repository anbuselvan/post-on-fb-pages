# Remove the job records every 10 minutes
SyncedCron.options.collectionTTL = 600

# Setup server startup configuration
Meteor.startup ->
  Meteor.publish "notifications", ->
    Notifications.find @userId

  Accounts.onCreateUser (options, user) ->
    console.log "User Logged In: ", user
    user

  # SMTP configuration
  smtp =
    username: "your_username"
    password: "your_password"
    server: "smtp.gmail.com"
    port: 25
    canSend: false

  # Setup the environment variable to send email
  if smtp.canSend
    process.env.MAIL_URL = "smtp://" + encodeURIComponent(smtp.username) + ":" + encodeURIComponent(smtp.password) + "@" + encodeURIComponent(smtp.server) + ":" + smtp.port
  else
    delete process.env.MAIL_URL

  # Send notification email
  notifyUserByEmail = (to, from, subject, text) ->
    check [
      to
      from
      subject
      text
    ], [String]
    Email.send
      to: to
      from: from
      subject: subject
      text: text
    return


  # Retrieve token if user is logged in
  getToken = ->
    user = Meteor.user()
    if user and user.services and user.services.facebook and user.services.facebook.accessToken
      user.services.facebook.accessToken
    else
      null


  # Fetch the feed from facebook
  getFBPageFeed = (pageId) ->
    token = getToken()
    if token
      Meteor.http.call "GET", "https://graph.facebook.com/" + pageId + "/feed",
        params:
          access_token: token
    else
      null

  getFBProfilePic = ->
    token = getToken()
    if token
      Meteor.http.call "GET", "https://graph.facebook.com/me",
        params:
          access_token: token
          fields: "picture"
    else
      null

  getFBPages = ->
    token = getToken()
    if token
      Meteor.http.call "GET", "https://graph.facebook.com/me/accounts",
        params:
          access_token: token
    else
      null

  postFBComment = (feedId, msg) ->
    token = getToken()
    if token
      Meteor.http.call "POST", "https://graph.facebook.com/" + feedId + "/comments",
        params:
          access_token: token
          message: msg
    else
      null

  removeJobForPageFeed = (uid) ->

    #Remove the previous job
    SyncedCron.remove uid

    #Remove previous user feed info
    UserFeedInfo.remove uid

    #Remove the cronHistory
    SyncedCron._collection.remove name: uid
    return

  addJobForFeed = (id, uid, mins, pageId) ->

    #Create a new cron job
    SyncedCron.add
      name: uid
      schedule: (parser) ->
        parser.text "every " + mins + " mins"

      job: ->
        console.log "cron job scheduled for page: " + pageId + ", every " + mins + " minutes"
        note = Notifications.findOne(
          _id: id
          page: pageId
        )
        if note
          Notifications.update
            _id: id
            page: pageId
          ,
            $set:
              lastUpdated: new Date()
        else
          Notifications.insert
            _id: id
            page: pageId
            lastUpdated: new Date()
        return
    return


  #TODO: get the feed and notify user by email if any new items found
  createJobForPageFeed = (pageId, mins) ->
    user = Meteor.user()
    if user

      #Retrieve user id
      id = user._id

      #Create a unique id for each page
      uid = id + "_" + pageId

      #Remove all the previous job info
      removeJobForPageFeed uid

      #Create a new job when it has a valid interval
      if mins isnt "m"

        #Create new user feed info object
        feedInfo =
          _id: uid
          user: id
          page: pageId
          interval: mins
          lastUpdated: new Date()
          createdAt: new Date()

        UserFeedInfo.insert feedInfo

        #Add new cron job
        addJobForFeed id, uid, mins, pageId
      "ok"
    else
      null


  # Start the Cron jobs
  SyncedCron.start()

  # Server restarted? resume all the cron jobs
  userFeedList = UserFeedInfo.find().fetch()
  if userFeedList.length > 0
    console.log "resume polling"
    userFeedList.forEach (feed, index, ar) ->

      #Retrieve the unique id
      uid = feed._id

      #Retrieve user id
      id = feed.user

      #Remove all the previous job info
      removeJobForPageFeed uid

      #Add a new cron job
      addJobForFeed id, uid, feed.interval, feed.page
      return

  # Setup server methods for client call
  Meteor.methods

    # A simple echo message
    getEcho: (msg) ->
      check msg, String
      msg

    # Retrieve profile picture url from facebook
    getProfilePic: ->
      console.log "getProfilePic"
      @unblock()
      getFBProfilePic()

    # Rerieve list of pages from facebook
    getPages: ->
      console.log "getPages"
      @unblock()
      getFBPages()

    # Retrieve feed for given page id
    getPageFeed: (pageId) ->
      check pageId, String
      console.log "getPageFeed"
      getFBPageFeed pageId

    # Post comment for given feed id
    postComment: (feedId, msg) ->
      check feedId, String
      check msg, String
      console.log "postComment"
      postFBComment feedId, msg

    updateFeedPollingInterval: (pageId, mins) ->
      console.log "updateFeedPollingInterval"
      createJobForPageFeed pageId, mins

  return
