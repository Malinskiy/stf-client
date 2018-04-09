module Stf
  class URIValidator
    def validate(uri)
      return (uri =~ /\A#{URI::regexp(%w(http https))}\z/) != nil
    end
  end
end