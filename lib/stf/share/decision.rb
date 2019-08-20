require 'stf/log/log'

module Stf
  class Decision
    include Log

    # spec has some explanation and examples
    def tell_me(mine:, brother:, free:)
      result = if mine < 2
                 if free > 0
                   :take
                 else
                   :nothing
                 end

               elsif mine > 2 and free < 2 and (brother == 0 || mine > brother)
                 :return

               elsif mine > 2 and free < 2 and mine == brother
                 :lazyReturn

               elsif brother == 0
                 if free > 2
                   :take
                 else
                   :nothing
                 end

               elsif brother - mine >= 2
                 if free > 0
                   :take
                 else
                   :nothing
                 end

               elsif brother - mine == 1
                 if free > 2
                   :take
                 else
                   :nothing
                 end

               elsif brother == mine
                 if free > 4
                   :take
                 elsif free > 2
                   :lazyTake
                 else
                   :nothing
                 end

               else
                 :nothing
               end

      logger.debug "mine: #{mine} brother: #{brother} free: #{free} result: #{result}"
      result
    end

  end
end