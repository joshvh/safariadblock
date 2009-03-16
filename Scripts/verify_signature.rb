#!/usr/bin/ruby
if ARGV.length < 3
  puts "Usage: ruby verify_signature.rb update_archive public_key signature"
  exit
end

`echo "#{ARGV[2]}" | openssl enc -base64 -d > verify_signature.temp`
puts `openssl dgst -sha1 -binary < "#{ARGV[0]}" | openssl dgst -dss1 -verify "#{ARGV[1]}" -signature verify_signature.temp`
`rm verify_signature.temp`
