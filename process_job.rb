class ProcessJob
  attr_reader :array

  def self.proccess_job(string)
    new(string).process_job
  end

  def initialize(string)
    @array = string.split(',')
  end

  # takes array made from string and turns to hash,
  # processes errors and kicks off order
  def process_job
    result = array.map do |x|
      x = x.split('=>')
      y = ret_y(x)
      Hash[x.first, y]
    end
    result = result.reduce(:merge)
    circular_error = check_circular(result)
    dependecy_error = result.select { |k, v| k == v }.count
    sort_jobs(result, circular_error, dependecy_error)
  end

  private

  def ret_y(xval)
    xval.length == 1 ? nil : xval.last
  end

  # takes hash and checks if any errors,
  # of so prints them else processes hash for ordering
  def sort_jobs(result, circular_error, dependecy_error)
    job_order = result.keys
    if circular_error.zero? && dependecy_error.zero?
      result.each { |key, val| switch_jobs(key, val, job_order) }
      job_order.join
    else
      print_errors(circular_error, dependecy_error)
    end
  end

  # prints errors
  def print_errors(circular_error, dependecy_error)
    if circular_error != 0 && dependecy_error != 0
      'error, jobs can’t depend on themselves and have circular dependencies'
    elsif circular_error != 0 && dependecy_error.zero?
      'error, jobs can’t have circular dependecies'
    else
      'error, jobs can’t depend on themselves'
    end
  end

  # iteration through hash, it takes existing val
  # and deletes from original order,
  # finds the index of the key of the depencie and inserts the val in front
  def switch_jobs(key, val, job_order)
    return if val.nil?
    job_order.delete(val)
    job_order_index = job_order.index(key)
    job_order.insert(job_order_index, val)
  end

  # checks for circular errors
  def check_circular(result)
    circular = 0
    result.each do |k, v|
      order = ret_order(result, k, v)
      next unless order.select { |x| x.last.nil? }.count.zero?
      array1 = order.map(&:first).sort
      array2 = order.map(&:last).sort
      circular += 1 if array1 == array2
    end
    circular
  end

  def ret_order(result, key, value)
    result.sort.select \
      { |x| x[0] == key || x[1] == key || x[0] == value || x[1] == value }
  end
end
