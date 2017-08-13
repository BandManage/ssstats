
class Ssstats

  # TODO 2-sigma stats
  CURRENTLY_AVAILABLE = %i[qty min max sum avg std]

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

  def stats
    clone @stats
  end

  def stat(key)
    @stats.transform_values{|col| col[key]}.compact
  end

  CURRENTLY_AVAILABLE.each do |calc|
    define_method calc do
      stat calc
    end
  end

  private

  def stat_schema(datum, schema, stats, path=[])
    stat_add path.join('.'), datum

    if datum.respond_to? :keys
      (schema || {}).tap do |schema|
        datum.keys.each do |key|
          key_s = key.to_s
          key_s += "'"  while schema[key_s] && class_of(schema[key_s]) != class_of(datum[key])
          schema[key_s] = stat_schema(datum[key], schema[key_s], stats, path + [key_s])
        end
      end
    elsif datum.respond_to? :each
      (schema || []).tap do |schema|
        datum.each do |el|
          el_schema = schema.find{|e| class_of(e) == class_of(el)}
          new_schema = stat_schema(el, el_schema, stats, path + [class_of(datum)])
          schema << new_schema  unless el_schema
        end
      end
    else
      if datum.class.respond_to? :new
        datum.class.new
      else
        rep_class = datum.class
        while rep_class  # NOTE this complication is due to cases like the Fixnum's
          return send rep_class.name, 0  if Kernel.respond_to? rep_class.name  # NOTE the case of Numeric's
          rep_class = rep_class.superclass
        end
        fail "Can't represent #{datum} (#{datum.class.name})"
      end
    end
  end

  def stat_add(key, val)
    stat_key = [key, class_of(val)].join('.')
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
    num_stat_min_max stat, num
    num_stat_sum stat, num
    num_stat_avg_std stat, num
  end

  def stat_count(stat)
    stat[:qty] ||= 0
    stat[:qty] += 1
  end

  def num_stat_min_max(stat, num)
    stat[:min] ||= num
    stat[:min] = num  if num < stat[:min]
    stat[:max] ||= num
    stat[:max] = num  if num > stat[:max]
  end

  def num_stat_sum(stat, num)
    stat[:sum] ||= 0
    stat[:sum] += num
  end

  def num_stat_avg_std(stat, num)
    # NOTE ref https://www.johndcook.com/blog/standard_deviation
    stat[:avg] ||= 0.0
    avg_was = stat[:avg]
    stat[:avg] += (num - avg_was) / stat[:qty]  # NOTE qty is not zero here
    stat[:delta_squares_sum] ||= 0.0
    stat[:delta_squares_sum] += (num - avg_was) * (num - stat[:avg])
    stat[:std] = Math.sqrt(stat[:delta_squares_sum] / stat[:qty])
  end

  def clone(thing)
    Marshal.load Marshal.dump thing
  end

  def class_of(datum)
    if datum.respond_to? :keys
      Hash
    elsif datum.respond_to? :each
      Array
    else
      datum.class
    end
  end
end
