# get gid based on group name

require 'etc'

module Puppet::Parser::Functions
  newfunction(:get_gid, :type => :rvalue, :doc => <<-EOS
    Get gid based on group name.
    EOS
  ) do |args|

    raise(Puppet::ParseError, 'get_uid(): Wrong number of arguments ' + "given (#{args.size} for 1)") if args.size != 1
    	Etc.group { |g|
    		if(g.name == args[0])
    			return g.gid
    		end
    	}
  	end
end
