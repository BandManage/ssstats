RSpec.describe Ssstats do

  it "has a version number" do
    expect(Ssstats::VERSION).not_to be nil
  end

  it "stats (and schemes) unstructured data" do
    subject << {weather: {temperature: 32.0}, score: {'Real' => 2, 'Barcelona' => 2}}
    subject << {weather: "freezing", score: {'Real' => 1, 'Barcelona' => 0}}

    expect(subject.schema).to(
      eq "weather" => {"temperature" => 0.0}, "weather'" => "", "score" => {"Real" => 0, "Barcelona" => 0}
    )
    expect(subject.avg).to(
      eq ".Hash.length" => 2.0, "weather.Hash.length" => 1.0, "weather.temperature.Float" => 32.0,
         "score.Hash.length" => 2.0, "score.Real.Integer" => 1.5, "score.Barcelona.Integer" => 1.0, "weather'.String.length" => 8.0
    )
  end

  it "collects useful statistics off simply (and loosely) structured data" do
    subject << {did: '6978a678d79e', ts: 1234567890, sd: [{os: 123, hz: 55.66}, {os: 101, hz: 56.56}, {os: 77, hz: 54.45}, {os: 39, hz: 57.99}]}
    subject << {did: '6978a678d79e', ts: 1234568901, sd: [{os: 104, hz: 53.56}, {os: 73, hz: 52.25}]}
    subject << {did: '6978a678d79e', ts: 1234569012, sd: []}
    subject << {did: '6978a678d79e', ts: 1234569999, sd: [{os: 0, error: 404}]}

    expect(subject.schema).to(
      eq 'did' => "", 'ts' => 0, 'sd' => [{'os' => 0, 'hz' => 0.0, 'error' => 0}]
    )

    expect(subject.sd).to(
      eq '.Hash.length' => 0.0, 'ts.Integer' => 746.7002410606281, 'sd.Array.length' => 1.479019945774904, 'sd.Array.Hash.length' => 0.0, 'sd.Array.os.Integer' => 39.17152235062235,
         'sd.Array.hz.Float' => 1.9022391776243297, 'sd.Array.error.Integer' => 0.0, 'did.String.length' => 0.0
    )
  end

  it "collects useful statistics off oddly structured data" do
    subject << {uid: '6978a678d79e', ts: 1234567890, sdHz: [55.66, 56.56, 54.45, 57.99], sdOs: [123, 101, 77, 39]}
    subject << {uid: '6978a678d79e', ts: 1234568901, sdHz: [53.56, 52.25], sdOs: [104, 73]}
    subject << {uid: '6978a678d79e', ts: 1234569012, sdHz: [], sdOs: []}

    expect(subject.schema).to(
      eq 'uid' => "", 'ts' => 0, 'sdHz' => [0.0], 'sdOs' => [0]
    )

    expect(subject.sd).to(
      eq '.Hash.length' => 0.0, 'ts.Integer' => 504.79104587938167, 'sdHz.Array.length' => 1.632993161855452, 'sdHz.Array.Float' => 1.9022391776243297,
         'sdOs.Array.length' => 1.632993161855452, 'sdOs.Array.Integer' => 27.00874344026804, 'uid.String.length' => 0.0
    )
  end
end
