unless typeof MochaWeb is "undefined"
  MochaWeb.testOnly ->
    describe "CLIENT: check server method call", ->
      it "should be available", ->
        Meteor.call "getEcho", "hello", (err, result) ->
          chai.assert.equal result, "hello"
          return

        return

      return

    return


# describe("CLIENT: login with facebook", function(){
#   it("should be failed", function(){
#     Meteor.loginWithFacebook({ requestPermissions: ['email', 'user_status', 'manage_pages', 'publish_actions' ]},
#         function (error, result) {
#         chai.assert(error !== undefined);
#     });
#   });
# });
