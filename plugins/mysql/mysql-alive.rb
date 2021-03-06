#!/usr/bin/env ruby
#
# MySQL Alive Plugin
# ===
#
# This plugin attempts to login to mysql with provided credentials.
#
# Copyright 2011 Joe Crim <josephcrim@gmail.com>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems'
require 'sensu-plugin/check/cli'
require 'mysql'

class CheckMySQL < Sensu::Plugin::Check::CLI

  option :user,
         :description => "MySQL User",
         :short => '-u USER',
         :long => '--user USER'

  option :password,
         :description => "MySQL Password",
         :short => '-p PASS',
         :long => '--password PASS'

  option :hostname,
         :description => "Hostname to login to",
         :short => '-w',
         :long => '--hostname HOST',
         :default => 'localhost'

  option :database,
         :description => "Database to use",
         :short => '-d',
         :long => '--database DATABASE',
         :default => 'test'

  def run
    begin
      db = Mysql.real_connect(config[:hostname], config[:user], config[:password], config[:database])
      info = db.get_server_info
      ok "Server version: #{info}"
    rescue Mysql::Error => e
      critical "Error message: #{e.error}"
    ensure
      db.close if db
    end
  end

end
