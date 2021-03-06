#!/usr/bin/env ruby
#
# This handler creates and resolves PagerDuty incidents, refreshing
# stale incident details every 30 minutes
#
# Copyright 2011 Sonian, Inc <chefs@sonian.net>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems'
require 'sensu-handler'
require 'redphone/pagerduty'

class Pagerduty < Sensu::Handler

  def incident_key
    @event['client']['name'] + '/' + @event['client']['environment'] + '/' + @event['check']['name']
  end

  def handle
    if @event['client'].has_key?('partners')
      partners_str = "PARTNERS: #{@event['client']['partners'].join(', ')}"
    else
      partners_str = ""
    end

    if @event['client']['environment']
      description = @event['notification'] || [@event['client']['name'], @event['client']['environment'], @event['check']['name'], partners_str, @event['check']['output'], @event['client']['subscriptions']].join(' : ')
    else
      description = @event['notification'] || [@event['client']['name'], @event['check']['name'], partners_str, @event['check']['output']].join(' : ')
    end
    begin
      timeout(3) do
        response = case @event['action']
                   when 'create'
                     Redphone::Pagerduty.trigger_incident(
                                                          :service_key => settings['pagerduty']['api_key'],
                                                          :incident_key => incident_key,
                                                          :description => description,
                                                          :details => @event
                                                          )
                   when 'resolve'
                     Redphone::Pagerduty.resolve_incident(
                                                          :service_key => settings['pagerduty']['api_key'],
                                                          :incident_key => incident_key
                                                          )
                   end
        if response['status'] == 'success'
          puts 'pagerduty -- ' + @event['action'].capitalize + 'd incident -- ' + incident_key
        else
          puts 'pagerduty -- failed to ' + @event['action'] + ' incident -- ' + incident_key
        end
      end
    rescue Timeout::Error
      puts 'pagerduty -- timed out while attempting to ' + @event['action'] + ' a incident -- ' + incident_key
    end
  end

end
