class Demonizer
  def initialize(dante, opts = {})
    @dante = dante

    @pid_path = opts[:pid_path].to_s.empty? ? '/tmp/stf-client.pid' : opts[:pid_path]
    @log_path = opts[:log_path].to_s.empty? ? '/tmp/stf-client.log' : opts[:log_path]
  end

  def run
    @dante.execute(daemonize: true,
                   pid_path: @pid_path,
                   log_path: @log_path) { yield }
  end

  def kill
    @dante.execute(kill: true, pid_path: @pid_path)
  end
end