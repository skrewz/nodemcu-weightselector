local M
do
  local self = {
    pin_user1 = 1,
    pin_user2 = 2
  }

  local early = function()
    gpio.mode(self.pin_user1,gpio.INPUT,gpio.PULLUP)
    gpio.mode(self.pin_user2,gpio.INPUT,gpio.PULLUP)
  end

  local main = function()
    mqttwrap.subscribe("datainput/bathroom/scale/raw",0)
    -- FIXME: this overlaps with default setup
    -- - TODO: a proper subscribe-handler setup is necessary in mqttwrap!
    mqttwrap.on("message", function(topic, data)
      print("inbound publish on ".. topic .. ":" )
      if data ~= nil then
        print(data)
      end
      if "datainput/bathroom/scale/raw" == topic then
        rawval = tonumber(data)
        val_user1 = gpio.read(self.pin_user1)
        val_user2 = gpio.read(self.pin_user2)
        print(string.format("user1=%d user2=%d",val_user1,val_user2))
        if 0 == val_user1 then
          name_chosen = "user1"
        elseif 0 == val_user2 then
          name_chosen = "user2"
        else
          return
        end
        local tm = rtctime.epoch2cal(rtctime.get())
        buf = string.format('{"ts":"%04d-%02d-%02dT%02d:%02d:%02dZ","type":"weightinput","location": "%s", "device":"%s","name":"%s","weight":%.3f}',
        tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"],
        location,
        myname,
        name_chosen,
        rawval)
        print("buf is:"..buf)
        mqttwrap.maybepublish("datainput/bathroom/scale/selected", buf, 0, 0)
      end
      if "command/settings/"..myname.."/location" == topic then
        flashsettings.set("location",data)
        node.restart()
      end
      if "command/flash/"..myname == topic then
        print ("Got hit on commands/flash/"..myname.." so flashing...")
        LFS.HTTP_OTA('192.168.1.10', '/imgs/', myname..'.img')
      end
    end)
  end

  -- expose
  M = {
    early = early,
    main = main,
  }
end
return M
