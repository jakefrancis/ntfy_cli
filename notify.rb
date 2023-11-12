#!/usr/bin/env ruby

require 'optparse'
require 'net/http'
require 'uri'

module Notify
    DEFAULT_TOPIC = 'mytopic'

    def self.send_message(message, topic = DEFAULT_TOPIC)
      # Define the base URL
      base_url = 'https://ntfy.sh'
  
      # Ensure the leading slash for the default topic
      topic = '/' + topic unless topic.start_with?('/')
  
      # Create the full URL
      url = "#{base_url}#{topic}"
  
      # Make an HTTP POST request to the specified URL
      uri = URI(url)
      http = Net::HTTP.new(uri.host)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = message
  
      begin
        response = http.request(request)
        if response.is_a?(Net::HTTPSuccess)
          return "Message Sent: #{message}"
        else
          return "Error: #{response.code} - #{response.message}"
        end
      rescue StandardError => e
        return "Error: #{e.message}"
      end
    end
  
    def self.cli
      # Parse command line options
      options = {}
      OptionParser.new do |opts|
        opts.banner = 'Usage: notify [options] message'
  
        opts.on('-t', '--topic TOPIC', 'Specify the topic') do |custom_topic|
          options[:topic] = custom_topic
        end
  
        opts.on('-h', '--help', 'Print this help message') do
          puts opts
          exit
        end
      end.parse!

       # Get the message from either command line arguments or stdin
        message = $stdin.tty? ? ARGV.join(' ') : $stdin.read
  
      # Check if a message is provided
      if message.empty?
        puts 'Error: Please provide a message.'
        exit 1
      end
  
      result = send_message(message, options[:topic] || DEFAULT_TOPIC)
      puts result
    end
  end
  
  # Check if the script is run as a command-line tool or used as a module
  if $PROGRAM_NAME == __FILE__
    Notify.cli
  end