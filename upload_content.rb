#!/usr/bin/env ruby

require 'fileutils'

bucket = ENV['CONTENT_BUCKET'] || raise('No BUCKET set')

ENV['AWS_ACCESS_KEY_ID'] = ENV['CONTENT_AWS_ACCESS_KEY_ID']
ENV['AWS_SECRET_ACCESS_KEY'] = ENV['CONTENT_AWS_SECRET_ACCESS_KEY']

Dir.chdir('content') do
  FileUtils.mkdir_p('remotes')

  Dir.glob('shelves/*.yml').each do |file|
    prefix = file.split('/').last.split('.').first

    cmd = "madlibrarian upload '#{file}' '#{bucket}' '#{prefix}'"
    remote = "'remotes/#{prefix}.yml'"
    meta = "'s3://#{bucket}/meta/#{prefix}.yml'"

    system("#{cmd} > #{remote}") || raise("Content failed: #{prefix}")
    aws_bin = File.expand_path '~/.local/bin/aws'
    system("#{aws_bin} s3 cp #{remote} #{meta}") || raise("Meta failed: #{prefix}")
  end
end
