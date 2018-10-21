class Hash
  # {id: 1, children: [{id: 2}, {id: 3, value: "Bingo"}]}.search({id: 3}) => {result: <Hash::>, path: [:children, 1]'}
  def search(key_value, path = [])
    target_key = key_value.keys.first
    target_value = key_value.values.first
    
    self.each do |k, v|
      if k == target_key && v == target_value
        return {result: self, path: path}
      elsif v.is_a?(Hash)
        nested_search = v.search(key_value, path + [k])
        return nested_search unless nested_search.nil?
      elsif v.is_a?(Array)
        v.each_with_index do |array_value, i|
          if array_value.is_a?(Hash)
            nested_search = array_value.search(key_value, path + [k, i])
            return nested_search unless nested_search.nil?
          end
        end
      end
    end
    return nil
  end
  
  # {id: 1, children: [{id: 2}, {id: 3, value: "Bingo"}]}.nested_values(:id) => [1, 2, 3]
  def nested_values(key)
    result = []
    self.each do |k, v|
      if k == key
        result.push(v)
      elsif v.is_a?(Hash)
        result += v.nested_values(key)
      elsif v.is_a?(Array)
        v.each do |array_value|
          if array_value.is_a?(Hash)
            result += array_value.nested_values(key)
          end
        end
      end
    end
    result
  end
end
