require 'ssstats/version'

class Ssstats

  def initialize
    @stats = {}
    @schema = {}
  end

  def <<(datum)
    stat_schema datum, @schema, @stats
  end

  def schema
    clone @schema
  end

  def stat(key)
    stats.transform_values{|col| col[key]}.compact
  end

  def count
    stat :count
  end

  def count
    stat :sum
  end

  def avg
    stat :avg
  end

  def sd
    stat :sd
  end

  private

  def stats
    clone @stats
  end

  def stat_schema(datum, schema, stats, path=[])
    stat_add path.join('.'), datum

    if datum.respond_to? :keys
      (schema || {}).tap do |schema|
        datum.keys.each do |key|
          key_s = key.to_s
          key_s += "'"  while schema[key_s] && schema[key_s].class != datum[key].class
          schema[key_s] = stat_schema(datum[key], schema[key_s], stats, path + [key_s])
        end
      end
    elsif datum.respond_to? :each
      (schema || []).tap do |schema|
        datum.each do |el|
          el_schema = schema.find{|e| e.class == el.class}
          new_schema = stat_schema(el, el_schema, stats, path + [datum.class.name])
          schema << new_schema  unless el_schema
        end
      end
    else
      if datum.class.respond_to? :new
        datum.class.new
      elsif Kernel.respond_to? datum.class.name  # NOTE the case of Numeric's
        send datum.class.name, 0
      else
        fail "Can't represent #{datum}"
      end
    end
  end

  def stat_add(key, val)
    stat_key = [key, val.class.name].join('.')
    val_stat = @stats[stat_key] ||= {}
    stat_count val_stat

    if val.respond_to? :length
      len_stat = @stats[[stat_key, 'length'].join '.'] ||= {}
      stat_count len_stat
      num_stat len_stat, val.length
    end

    num_stat val_stat, val  if val.is_a? Numeric
  end

  def num_stat(stat, num)
    stat[:sum] ||= 0
    stat[:sum] += num
    stat[:avg] ||= 0.0
    # NOTE ref https://www.johndcook.com/blog/standard_deviation
    avg_was = stat[:avg]
    stat[:avg] += (num - avg_was) / stat[:count]  # NOTE count is not zero here
    stat[:delta_squares_sum] ||= 0.0
    stat[:delta_squares_sum] += (num - avg_was) * (num - stat[:avg])
    stat[:sd] = Math.sqrt(stat[:delta_squares_sum] / stat[:count])
  end

  def stat_count(stat)
    stat[:count] ||= 0
    stat[:count] += 1
  end

  def clone(thing)
    Marshal.load Marshal.dump thing
  end
end
