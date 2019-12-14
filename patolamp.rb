require "aws_iot_device"
require 'taopaipai'

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

def set_patolamp(lighting)
  target_pin_number = 3
  # パトランプに疎通するとき 0 なので注意
  Taopaipai.gpio.pin(target_pin_number, direction: :out, value: lighting ? 0 : 1)
end

def set_reported_state(shadow_client, lighting)
  filter_callback = Proc.new do |message|
    puts "update reported"
  end

  json_payload = "{\"state\":{\"reported\":{\"lighting\":#{lighting}}}}"
  timeout = 5 # seconds
  shadow_client.update_shadow(json_payload, timeout, filter_callback)
end

delta_callback = Proc.new do |delta|
  puts 'delta detected'
  message = JSON.parse(delta.payload)
  lighting = message["state"]["lighting"] # パトランプの点灯状態
  return if lighting != true && lighting != false
  set_patolamp(lighting)
  set_reported_state(shadow_client, lighting)
end

begin
  shadow_client.register_delta_callback(delta_callback)

  lighting = false # パトランプが消えている状態で初期化
  set_patolamp(lighting)
  set_reported_state(shadow_client, lighting)

  loop { sleep 1 }
ensure
  shadow_client.disconnect
  Taopaipai.gpio.release
end
