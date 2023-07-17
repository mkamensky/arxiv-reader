# frozen_string_literal: true

class Hash
  def vdeep_merge(other_hash, &block)
    deep_merge(other_hash) do |key, orig, merged|
      if orig.respond_to?(:union)
        orig.union(merged)
      elsif block
        yield key, orig, merged
      else
        merged
      end
    end
  end
end

