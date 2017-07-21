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

  def avg
    stats.transform_values{|col| col[:avg]}.compact
  end

  private

  # TODO be lazy
  def stats
    clone @stats
  end

  def stat_schema(datum, schema, stats, path=[])
    stat_add path.join('.'), datum

    if datum.respond_to? :keys
      (schema || {}).tap do |schema|
        datum.keys.each do |key|
          key_s = key.to_s
          schema[key_s] = combine_schema(schema[key_s], stat_schema(datum[key], schema[key_s], stats, path + [key_s]))
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
    stat[:avg] = stat[:sum].to_f / stat[:count]
  end

  def stat_count(stat)
    stat[:count] ||= 0
    stat[:count] += 1
  end

  def combine_schema(curr_rep, new_rep)
    if !curr_rep
      new_rep
    elsif curr_rep.is_a?(Array) && !curr_rep.empty?
      curr_rep + [new_rep]  unless curr_rep.any?{|r| r.class == new_rep.class}
    elsif curr_rep != new_rep
      [curr_rep, new_rep]
    else
      curr_rep
    end
  end

  def clone(thing)
    Marshal.load Marshal.dump thing
  end
end
