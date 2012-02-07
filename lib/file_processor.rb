class FileProcessor
  # DEFAULT_FILE_PATH = "/Volumes/ubuntu-dev/grunt/lib/aggregation/generic/accounts/base_account.rb"
  MAX_COMBINED_ELEMENTS = 10
  
  # def self.score_file(file_path = DEFAULT_FILE_PATH)
  def self.score_file(file_path)
    file_contents = get_file_contents(file_path)
    file_elements = tokenize_file_contents(file_contents) 
    file_elements_scored = score_file_elements(file_elements)
    # highest_scoring_elements = compute_highest_scoring_elements(file_elements_scored)
    file_score = compute_file_score(file_elements_scored)
    file_duplication_density = compute_file_duplication_density(file_score, file_contents)
    # puts ""
    # puts file_score
    # puts file_duplication_density
    return {:file_score => file_score, :file_duplication_density => file_duplication_density}
  end
  
  private
  
  def self.get_file_contents(file_path)
    IO.read(file_path)
  end
  
  def self.tokenize_file_contents(file_contents)    
    file_contents.split(/\s+/)
  end
  
  def self.score_file_elements(file_elements)
    # Determine how many times each element occurs
    file_elements_hash = Hash.new(0)
    file_elements.each_with_index do |file_element, index|
      file_elements_hash[file_element] += 1

      # Combine this element with the ones that came before it so we identify recurring sequences of elements
      # which is the best indication of code duplication
      (1..MAX_COMBINED_ELEMENTS).each do |places_back|
        start_position = index - places_back
        next if start_position < 0
        file_elements_combined = file_elements[start_position..index].join(" ")
        file_elements_hash[file_elements_combined] += 1
      end
    end

    # Score each element according to its occurance and length
    file_elements_scored = {}
    file_elements_hash.each do |element, count|
      score = (count * element.split(' ').size) ** 2
      file_elements_scored[element] = score
    end
      
    return file_elements_scored
  end
  
  def self.compute_highest_scoring_elements(file_elements_scored, max_index = 10)
    file_elements_scored.sort {|a,b| b[1] <=> a[1]}.each_with_index do |elem, index|
      p elem
      # break if max_index != :all && index < max_index
      break if ((index + 1 >= max_index) && (max_index != :all))
    end
  end
  
  def self.compute_file_score(file_elements_scored)
    file_score = 0
    file_elements_scored.each do |element, score|
      file_score += score
    end
    
    return file_score
  end
  
  def self.compute_file_duplication_density(file_score, file_contents)
    file_score / file_contents.size
  end
end
