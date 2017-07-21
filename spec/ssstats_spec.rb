RSpec.describe Ssstats do

  it "has a version number" do
    expect(Ssstats::VERSION).not_to be nil
  end

  it "stats (and schemes) unstructured data" do
    subject << {weather: {temperature: 32.0}, score: {'Real' => 2, 'Barcelona' => 2}}
    subject << {weather: "freezing", score: {'Real' => 1, 'Barcelona' => 0}}

    expect(subject.schema).to(
      eq 'weather' => [{'temperature' => 0.0}, ""], 'score' => {'Real' => 0, 'Barcelona' => 0}
    )
    expect(subject.avg).to(
      eq '.Hash.length' => 2.0, 'weather.Hash.length' => 1.0, 'weather.temperature.Float' => 32.0, 'score.Hash.length' => 2.0,
         'score.Real.Integer' => 1.5, 'score.Barcelona.Integer' => 1.0, 'weather.String.length' => 8.0
    )
  end
end
