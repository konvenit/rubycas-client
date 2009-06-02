class Hash
  def nullify(*args)
    result = {}
    args.each { |a| result[a] = nil }
    merge result
  end
end


class TextRenderer

  def initialize
    @filters = {}
  end

  def render(text, variables = {})
    apply variables, text
  end

  def add_helpers(mod)
    extend mod
  end

  def add_filter(marker, filter)
    @filters[marker] = filter
  end

  private
    def apply(variables, text)
      text.to_s.gsub(/\{.+?\}/) do |m|
        segs = m.gsub(/\{|\}/, '').split(' ')

        if segs.first.first == "%"
          apply_explicit_helper(variables, segs)
        elsif @filters.keys.include?(segs.first.first)
          apply_filter(segs, segs.first.first, @filters[segs.first.first], variables)
        else
          apply_substitution(variables, segs)
        end
      end
    end

    def apply_explicit_helper(variables, segs)
      if segs.size == 1
        send segs.first.sub("%", "")
      else
        send segs.first.sub("%", ""), variables.retrieve_variable(segs[1]), *segs[2..-1]
      end
    end

    def apply_substitution(variables, segs)
      if segs.size > 1
        send segs.first, variables.retrieve_variable(segs[1]), *segs[2..-1]
      else
        variables.retrieve_variable segs.first
      end
    end

    def apply_filter(segs, marker, filter, variables)
      if segs.size == 1
        filter.generate segs.first.sub(marker, "")
      elsif segs.size == 2
        filter.generate segs.first.sub(marker, ""), variables.retrieve_variable(segs[1])
      else
        filter.generate segs.first.sub(marker, ""), variables.retrieve_variable(segs[1]), *segs[2..-1]
      end
    end

end
