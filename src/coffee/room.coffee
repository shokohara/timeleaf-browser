#$ ->
##  $('.menu .item').tab()
##  $(".item").popup(on: "hover")
#
#class SoundPreferences
#  constructor: (roomId) ->
#    @Sound = "sound"
#    @Join = "join"
#    @Talk = "talk"
#    @roomId = roomId
#    @joinSoundKey = @Sound + "-" + @roomId + "-" + @Join
#    @talkSoundKey = @Sound + "-" + @roomId + "-" + @Talk
#    unless localStorage[@joinSoundKey]? then localStorage[@joinSoundKey] = true
#    unless localStorage[@talkSoundKey]? then localStorage[@talkSoundKey] = false
#  isEnableJoinSound: -> localStorage[@joinSoundKey] == "true"
#  isEnableTalkSound: -> localStorage[@talkSoundKey] == "true"
#  setJoinSound: (value)-> localStorage[@joinSoundKey] = value
#  setTalkSound: (value)-> localStorage[@talkSoundKey] = value
#  playJoinSound: -> new Howl(urls: ["/assets/sounds/chat_start.mp3"]).play()
#  playTalkSound: -> new Howl(urls: ["/assets/sounds/message_receive.mp3"]).play()
#
#resizeTalksContainerHeight = ->
#  uiStackedSegmentPaddingVertical = $(".twelve.wide.column>.ui.stacked.segment").innerHeight() - $(".twelve.wide.column>.ui.stacked.segment").height() + 10
#  labelHeight = $(".twelve.wide.column>.ui.stacked.segment>.ui.attached.top.label").outerHeight(true)
#  navbarHeight = 0
#  menuHeight = $(".ui.menu").outerHeight(true)
#  inputContainerHeight = $(".input-container").outerHeight(true)
#  talksContainerHeight = $(window).outerHeight(true) - navbarHeight - menuHeight - uiStackedSegmentPaddingVertical - labelHeight - inputContainerHeight
#  $(".talks-container").height(talksContainerHeight)
#
##host = purl().attr("host")
##port = purl().attr("port")
##path = purl().attr("path")
##directory = purl().attr("directory")
#roomId = ""
#for character in path.split("").reverse()
#  if character is "/" then break else roomId = roomId + character
#
#zeroPad = (num, places)->
#  zero = places - num.toString().length + 1
#  return Array(+(zero > 0 && zero)).join("0") + num
#
#window.Controller = ($scope) ->
#  $scope.messages = []
#  $scope.typingMembers = []
#
#  WebSocket = window.WebSocket || window.MozWebSocket
#  websocket = new WebSocket("ws://#{host}:#{port}/ws/#{roomId}")
#  websocket.tryCatchSend = (object)->
#    websocket.send(JSON.stringify(object))
#
#  websocket.onopen = (event)->
#    #TODO WebSocket is already in CLOSING or CLOSED state.
#    #TODO onclose後のheartbeatが原因
#    heartbeat = ->
#      websocket.tryCatchSend []
#      _.delay(heartbeat, 10000)
#    heartbeat()
#
#  websocket.onmessage = (event)->
#    message = angular.fromJson(event.data)
#    console.log event.data
#    $scope.messages.push message
#    switch message.kind
#      when "join_result"
#        switch message.data.result
#          when "error"
#            $(".onOpen").hide()
#            $(".onError").show()
#            $(".onSuccess").hide()
#            $(".onClose").hide()
#          when "success"
#            $(".onOpen").hide()
#            $(".onError").hide()
#            $(".onSuccess").show()
#            $(".onClose").hide()
#            resizeTalksContainerHeight()
#      when "join"
#        $(".ui.selection.dropdown").dropdown()
#        if new SoundPreferences(roomId).isEnableJoinSound() then new SoundPreferences(roomId).playJoinSound()
#      when "typing"
#        if (user for user in $scope.typingMembers when user.id is message.data.id).length is 0
#          $scope.typingMembers.push(message.data)
#      when "typed"
#        $scope.typingMembers = (user for user in $scope.typingMembers when user.id isnt message.data.id)
#      when "talk"
#        if new SoundPreferences(roomId).isEnableTalkSound() then new SoundPreferences(roomId).playTalkSound()
#        $scope.$apply()
#        if $(".talk-container:last-child").position().top < $(".talks-container").outerHeight() + $(".talk-container").outerHeight()
#          sumOfTalkContainerHeights = _($(".talk-container").map((index, element)-> $(element).outerHeight(true))).reduce((previousValue, currentValue)-> previousValue + currentValue + 2)
#          $(".talks-container").stop().animate({scrollTop: sumOfTalkContainerHeights})
#      when "update_room_name"
#        $("#room-name-2").text(message.data.name)
#      when "update_room_owner"
#        $scope.$apply()
#      when "quit"
#        $scope.$apply()
#    $scope.$apply()
#    $(".ui.dropdown").dropdown()
#    $("img.user-icon").popup(on: "hover")
#
#  websocket.onclose = (event)->
#    $(".onClose").show()
#
#  $scope.up = (event)->
#    $scope.textLength = $scope.text.length
#    if $scope.text.length is 0
#      websocket.tryCatchSend kind: "typed"
#    else
#      websocket.tryCatchSend kind: "typing"
#  $scope.press = (event)->
#    $scope.textLength = $scope.text.length
#    if event.which is 13
#      websocket.tryCatchSend
#        kind: "talk"
#        data:
#          text: $scope.text
#      $scope.text = ""
#  $scope.down = (event)->
#    $scope.textLength = $scope.text.length
#
#  $scope.userId = -> parseInt($.cookie("id"))
#
#  $scope.showProfile = (id)-> $("#user-profile-#{id}").modal("show")
#  $scope.showAdminMenu = ->
#    $(".admin-menu.ui.modal").modal("show")
#    $(".ui.selection.dropdown").dropdown()
#  $scope.sendUpdateRoomOwner = (event)->
#    value = $(event.target).parent().find("input").attr("value")
#    parsedIntValue = parseInt(value)
#    websocket.tryCatchSend(
#      kind: "update_room_owner"
#      data:
#        id: parsedIntValue
#    )
#  $scope.sendUpdateRoomName = (event)->
#    value = $(event.target).parent().find("input:not(:hidden)").val()
#    websocket.tryCatchSend(
#      kind: "update_room_name"
#      data:
#        name: value
#    )
#
#  $scope.error = (message)-> message.kind is "error"
#  $scope.message = (message)-> message.kind is "talk"
#  $scope.joinQuit = (message)-> message.kind is "join" or message.kind is "quit"
#  $scope.typingTyped = (message)-> message.kind is "typing" or message.kind is "typed"
#  $scope.roomOwner = (message)-> message.kind is "update_room_owner" or message.kind is "room_owner"
#
#  $scope.isOwner = -> _.last($scope.messages.filter($scope.roomOwner)).data.user.id is $scope.userId()
#  $scope.isOwner = (id)-> _.last($scope.messages.filter($scope.roomOwner)).data.user.id is id
#
#  $scope.color = (id)->
#    membersMessages = (message for message in $scope.messages when message.kind is "join" or message.kind is "quit")
#    latestMembers = _.last(membersMessages)
#    targetMember = _.head(member for member in latestMembers.data.members when member.id is parseInt(id))
#    targetMember.color
#
#  $scope.isSupportBrowser = -> Modernizr.websockets
#
#$ ->
#  resizeTalksContainerHeight()
#  $(window).resize(resizeTalksContainerHeight)
#
#  $(".ui.checkbox.join").checkbox({
#    onEnable: -> new SoundPreferences(roomId).setJoinSound(true)
#    onDisable: -> new SoundPreferences(roomId).setJoinSound(false)
#  })
#  $(".ui.checkbox.talk").checkbox({
#    onEnable: -> new SoundPreferences(roomId).setTalkSound(true)
#    onDisable: -> new SoundPreferences(roomId).setTalkSound(false)
#  })
#  $("#sound-talk").prop("checked", new SoundPreferences(roomId).isEnableTalkSound())
#  $("#sound-join").prop("checked", new SoundPreferences(roomId).isEnableJoinSound())
#
#  $(".message > .close").click (e)-> $(this).closest(".message").hide()
#  $(".ui.dropdown").dropdown()
