# get uid based on user name

require 'etc'

module Puppet::Parser::Functions
  newfunction(:get_uid, :type => :rvalue, :doc => <<-EOS
    Get uid based on user name.
    EOS
  ) do |args|

    raise(Puppet::ParseError, 'get_uid(): Wrong number of arguments ' + "given (#{args.size} for 1)") if args.size != 1
    	Etc.passwd { |u|
    		if(u.name == args[0])
    			return u.uid
    		end
    	}
  	end
end
