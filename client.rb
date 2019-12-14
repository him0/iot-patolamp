require "aws_iot_device"

host = ENV["HOST"]
port = ENV["PORT"]
thing = ENV["THING"]

ca_file = ENV["CA_FILE"]
key_file = ENV["EKY_FILE"]
cert_file = ENV["CERT_FILE"]

shadow_client = AwsIotDevice::MqttShadowClient::ShadowClient.new
shadow_client.configure_endpoint(host, port)
shadow_client.configure_credentials(ca_file, key_file, cert_file)
shadow_client.create_shadow_handler_with_name(thing, true)
shadow_client.connect

filter_callback = Proc.new do |message|
  puts "Executing the specific callback for topic: #{message.topic}\n##########################################\n"
end

loop do
  puts "Type the message that you want to register in the thing:"
  entry = $stdin.readline()
  json_payload = "{\"state\":{\"desired\":{\"lighting\":#{entry.delete!("\n")}}}}"
  shadow_client.update_shadow(json_payload, 5, filter_callback)
end

sleep 3

shadow_client.disconnect
