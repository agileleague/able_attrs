module AbleAttrs
  class Opts
    def initialize(hash)
      @hash = hash || {}
    end

    def [](key)
      return @hash[key] if @hash.has_key?(key)

      case key
      when Symbol
        @hash[key.to_s]
      when String
        @hash[key.to_sym]
      else
        nil
      end
    end
  end
end
