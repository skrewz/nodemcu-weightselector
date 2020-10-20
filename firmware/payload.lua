local M
do
  local self = {
    pin_user1 = 1,
    pin_user2 = 2,
    currently_selected_user = nil,
    tmr_disable = nil,
  }

  -- Owing to https://gist.github.com/marcelstoer/75ba30a4aec56d1b3810
  local debounce = function (func)
      local last = 0
      local delay = 50000 -- 50ms * 1000 as tmr.now() has μs resolution

      return function (...)
          local now = tmr.now()
          local delta = now - last
          if delta < 0 then delta = delta + 2147483647 end; -- proposed because of delta rolling over, https://github.com/hackhitchin/esp8266-co-uk/issues/2
          if delta < delay then return end;

          last = now
          return func(...)
      end
  end


  local colour_effect = function (colour,effect)
    print("colour_effect("..colour..","..effect..")")
    if "red" == colour then
      ws2812_effects.set_color(0,255,0)
    elseif "green" == colour then
      ws2812_effects.set_color(255,0,0)
    elseif "blue" == colour then
      ws2812_effects.set_color(0,0,255)
    elseif "black" == colour then
      ws2812_effects.set_color(0,0,0)
    end

    print("setting mode: "..effect)
    ws2812_effects.set_mode(effect)
    ws2812_effects.start()
  end

  local disable = function ()
    print("disable() invoked")
    colour_effect("black","static")
    self.currently_selected_user = nil
  end

  local button_state_handler = function ()
    if nil ~= self.tmr_disable then
      self.tmr_disable:stop()
    end

    local u1_val = gpio.read(self.pin_user1)
    local u2_val = gpio.read(self.pin_user2)
    print ("button_state_handler, have user1="..u1_val.." user2="..u2_val)

    if 1 == u1_val and 1 == u2_val then
      self.currently_selected_user = nil
      colour_effect("black","static")
    elseif 0 == u1_val then
      self.currently_selected_user = 1
      colour_effect("blue","static")
    elseif 0 == u2_val then
      self.currently_selected_user = 2
      colour_effect("red","static")
    end

    self.tmr_disable:register(300000, tmr.ALARM_SINGLE, disable)
    self.tmr_disable:start()

  end

  local early = function()
    self.tmr_disable = tmr.create()
    ws2812.init(ws2812.MODE_SINGLE)
    self.strip_buffer = ws2812.newBuffer(1, 3)
    ws2812_effects.init(self.strip_buffer)
    ws2812_effects.set_speed(240)
    ws2812_effects.set_brightness(50)
    ws2812_effects.set_color(0,0,0)
    ws2812_effects.set_mode("static")
    ws2812_effects.start()

    gpio.mode(self.pin_user1,gpio.INT,gpio.PULLUP)
    gpio.mode(self.pin_user2,gpio.INT,gpio.PULLUP)
    gpio.trig(self.pin_user1, 'both', debounce(button_state_handler))
    gpio.trig(self.pin_user2, 'both', debounce(button_state_handler))

    button_state_handler()
  end

  local main = function()
    mqttwrap.subscribe("datainput/bathroom/scale/raw",0)
    mqttwrap.subscribe("datainput/bathroom/scale/published",0)


    -- When a "yes, published" message arrives, light up green to indicate
    -- success.
    mqttwrap.handletopic("datainput/bathroom/scale/published", function(topic, data)
      colour_effect("green","static")
      self.tmr_disable:register(600000, tmr.ALARM_SINGLE, disable)
      self.tmr_disable:start()
    end)

    -- A stringified float will arrive on this topic whenever the scale
    -- produces a new weighing.
    mqttwrap.handletopic("datainput/bathroom/scale/raw", function(topic, data)
      rawval = tonumber(data)

      if 1 == self.currently_selected_user then
        name_chosen = "user1"
      elseif 2 == self.currently_selected_user then
        name_chosen = "user2"
      else
        colour_effect("unmatched","random_color")
        self.tmr_disable:register(5000, tmr.ALARM_SINGLE, disable)
        self.tmr_disable:start()
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

      -- make the current color blink:
      colour_effect("unmatched","blink")
      mqttwrap.maybepublish("datainput/bathroom/scale/selected", buf, 0, 0)
    end)
  end

  -- expose
  M = {
    early = early,
    main = main,
  }
end
return M
