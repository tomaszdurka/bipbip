require 'bipbip'
require 'bipbip/plugin/janus_audioroom'

describe Bipbip::Plugin::JanusAudioroom do
  let(:plugin) { Bipbip::Plugin::JanusAudioroom.new('janus-audioroom', { 'url' => 'http://127.0.0.1:8088/janus' }, 10) }

  it 'should collect janus audioroom status data' do
    response = <<EOS
{
  "plugin": "janus.plugin.cm.audioroom",
  "data": {
    "audioroom": "success",
    "list": [
      {
        "sampling_rate": 16000,
        "record": "true",
        "id": "super-magic-room",
        "num_participants": 3,
        "description": "Room super-magic-room"
      },
      {
        "sampling_rate": 48000,
        "record": "true",
        "id": "super-fooboo-room",
        "num_participants": 7,
        "description": "Room super-fooboo-room"
      },
      {
        "sampling_rate": 16000,
        "record": "true",
        "id": "super-foo-boo",
        "num_participants": 0,
        "description": "Room super-foo-boo"
      }
    ]
  }
}
EOS

    allow(plugin).to receive(:_fetch_data).and_return(JSON.parse(response))

    data = plugin.monitor

    data['room_count'].should eq(3)
    data['participant_count'].should eq(10)
    data['room_zero_participant_count'].should eq(1)
  end

  it 'should handle empty list of rooms' do
    response = <<EOS
{
  "plugin": "janus.plugin.cm.audioroom",
  "data": {
    "audioroom": "success",
    "list": []
  }
}
EOS

    allow(plugin).to receive(:_fetch_data).and_return(JSON.parse(response))

    data = plugin.monitor

    data['room_count'].should eq(0)
    data['participant_count'].should eq(0)
    data['room_zero_participant_count'].should eq(0)
  end
end
