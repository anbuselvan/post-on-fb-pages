unless typeof MochaWeb is "undefined"
  MochaWeb.testOnly ->
    describe "SERVER: server initialization", ->
      it "should have a Meteor version defined", ->
        chai.assert Meteor.release
        return

      return

    describe "SERVER: facebook auth keys", ->
      it "should be empty", ->
        chai.assert Meteor.users.find().count() is 0
        return

      return

    describe "SERVER: check user object", ->
      it "should be undefined", ->
        chai.assert @userId is `undefined`
        return

      return

    describe "SERVER: accounts login service remove", ->
      it "should be removed", ->
        Accounts.loginServiceConfiguration.remove service: "facebook"
        chai.assert Accounts.loginServiceConfiguration.find().count() is 0
        return

      return

    describe "SERVER: accounts login service", ->
      it "should be empty", ->
        chai.assert Accounts.loginServiceConfiguration.find().count() is 0
        return

      return

    describe "SERVER: accounts login service insert", ->
      it "should be created", ->
        Accounts.loginServiceConfiguration.insert
          service: "facebook"
          clientId: "1512894942327477"
          secret: "37b3811c5730a253199cdcb30e0c45e6"

        chai.assert Accounts.loginServiceConfiguration.find().count() is 1
        return

      return

    describe "SERVER: verify accounts login service", ->
      it "should not be empty", ->
        chai.assert Accounts.loginServiceConfiguration.find().count() is 1
        return

      return

    return

