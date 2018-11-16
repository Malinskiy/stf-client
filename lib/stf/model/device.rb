module Stf
  class Device < OpenStruct
    def getValue(key)
      getValueFromObject(self, key)
    end

    def getKeys
      getKeysNextLevel('', self)
    end

    # more pessimistic decision
    def isHealthyForConnect(pattern)
      return true if pattern.nil?
      health = isHealthy(pattern)
      ppp = pattern.split(',')
      ppp.each do |p|
        health &&= getValue('battery.temp').to_i < 30 if ['t', 'temp', 'temperature'].include? p
        health &&= getValue('battery.level').to_f > 30.0 if ['b', 'batt', 'battery'].include? p
      end
      health
    end

    def isHealthy(pattern)
      return true if pattern.nil?
      ppp = pattern.split(',')
      health = true
      ppp.each do |p|
        health &&= getValue('battery.temp').to_i < 32 if ['t', 'temp', 'temperature'].include? p
        health &&= getValue('battery.level').to_f > 20.0 if ['b', 'batt', 'battery'].include? p
        health &&= getValue('network.connected') if ['n', 'net', 'network'].include? p
        health &&= getValue('network.type') == 'VPN' if ['vpn'].include? p
        health &&= getValue('network.type') == 'WIFI' if ['wifi'].include? p
      end
      health
    end

    def checkFilter(filter)
      return true if filter.nil?
      key, value = filter.split(':', 2)
      getValue(key) == value
    end

    def getKeysNextLevel(prefix, o)
      return [] if o.nil?

      o.each_pair.flat_map do |k, v|
        if v.is_a? OpenStruct
          getKeysNextLevel(concat(prefix, k.to_s), v)
        else
          [concat(prefix, k.to_s)]
        end
      end
    end

    def concat(prefix, key)
      prefix.to_s.empty? ? key : prefix + '.' + key
    end


    def getValueFromObject(obj, key)
      keys = key.split('.', 2)
      if keys[1].nil?
        obj[key]
      else
        getValueFromObject(obj[keys[0]], keys[1])
      end
    end

    private :getValueFromObject, :concat, :getKeysNextLevel

  end
end
