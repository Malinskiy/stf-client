class Session

  attr_accessor :serial, :url

  def initialize(serial, url)
    @serial = serial
    @url    = url
  end

end