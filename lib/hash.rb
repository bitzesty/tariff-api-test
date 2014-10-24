# taken from rails
# https://github.com/steveklabnik/rails/blob/88d59de12d9951c0ac18a1e53e52f92c00c15849/activesupport/lib/active_support/core_ext/hash/diff.rb

class Hash
  # Returns a hash that represents the difference between two hashes.
  #
  #   {1 => 2}.diff(1 => 2)         # => {}
  #   {1 => 2}.diff(1 => 3)         # => {1 => 2}
  #   {}.diff(1 => 2)               # => {1 => 2}
  #   {1 => 2, 3 => 4}.diff(1 => 2) # => {3 => 4}
  def diff(other)
    dup.
      delete_if { |k, v| other[k] == v }.
      merge!(other.dup.delete_if { |k, v| has_key?(k) })
  end
end
