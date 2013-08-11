module Sherlock
  class Strategy
    def initialize(problem, api: api, io: $stdout)
      @problem  = problem
      @api      = api
      @io       = io
      @continue = false
    end

    attr_reader :problem, :api, :io
    private     :problem, :api, :io

    attr_writer :continue
    private     :continue=

    def continue?
      @continue
    end

    def guess(program, &on_mismatch)
      loop do
        puts "Guessing:  #{program}"
        result, response = api.guess(problem["id"], program.to_s)
        if result == :success
          case response["status"]
          when "win"
            io.puts "Elementary!"
            self.continue = true
            break
          when "mismatch"
            input, output, guessed = response["values"].map { |hex|
              Integer(hex)
            }
            io.puts "Guess was wrong."
            io.puts "  Input:  #{input}"
            io.puts " Output:  #{output}"
            io.puts "Guessed:  #{guessed}"
            program = on_mismatch.call(input, output, guessed)
            if program.is_a?(String) && program.start_with?("(lambda")
              next
            else
              io.puts "No more guesses."
              break
            end
          else
            io.puts "Guess error:  #{response['message']}"
            break
          end
        else
          io.puts "Guess failed:  #{result.to_s.tr('_', ' ')}"
          break
        end
      end
    end
  end
end
