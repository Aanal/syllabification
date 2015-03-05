require "awesome_print"
require "csv"

legal_onsets = CSV.read('normalised_legal_onsets.csv')
$legal_onsets_hash = Hash[*legal_onsets.flatten(1)]



def is_vowel(char)
 	not char.gsub(/[aeiou]/).to_a.empty?
end

def is_consonant(char)
 	not char.gsub(/[^aeiou]/).to_a.empty?
end

def hyphenate(word)
	parts = []
	chars = word.split("")
	types = ["vowel" , "consonant"]
	types.reverse! if not eval("is_#{types.first}(chars.first)")
	part = []
	for char in chars
		if not eval("is_#{types.first}(char) ")
			types.reverse!	
			parts << part
			part = [char]
		else
			part << char
		end
	end
	parts << part
	parts.map(&:join).join("-")
end



def is_legal_onset(right)
	not $legal_onsets_hash[right].nil?
end

def frequency_of_onset(right)
	return 0 if $legal_onsets_hash[right].nil?
	$legal_onsets_hash[right]
end

def tag(hyphenated_word)
	parts = hyphenated_word.split("-")
	character_tag_array = parts.join().split("")
	character_tag_array.map!{|x| [x , "undefined"]}
	current_char_index = 0
	nuclie_count = 1
	
	confusing_parts = []
	
	parts.each do |part| 
		if part == parts.first and is_consonant(part[0])
			part.split("").each{|char| 
				character_tag_array[current_char_index][1] = "Onset:#{nuclie_count}"
				current_char_index += 1
			}
		elsif part == parts.last and is_consonant(part[0])
			part.split("").each{|char| 
				character_tag_array[current_char_index][1] = "Coda:#{nuclie_count - 1}"
				current_char_index += 1
			}
		elsif is_vowel(part[0])
			part.split("").each{|char| 
				character_tag_array[current_char_index][1] = "Nucleus:#{nuclie_count}"
				current_char_index += 1
			}
			nuclie_count += 1
		else
			confusing_parts << [ current_char_index , current_char_index + part.size - 1 , "#{nuclie_count-1}-#{nuclie_count}" ,  part ]
			current_char_index += part.size		
		end
	end

	# ##Solve the confusing part using MOP


 # 	for confusing_part in confusing_parts
 # 		left = [] ; right = confusing_part.slice(3,1).first.split("")
 # 		while not is_legal_onset(right.join()) do
 # 			left.unshift(right.shift) 			
 # 		end
 # 		confusing_indices = (confusing_part[0]..confusing_part[1]).to_a
 # 		confusing_indices_left = confusing_indices.take(left.size)
 # 		confusing_indices_right = confusing_indices - confusing_indices_left
 # 		left_syllable_index , right_syllable_index = confusing_part[2].split("-").map(&:to_i)

 # 		confusing_indices_left.each{|index| character_tag_array[index][1] = "Coda:#{left_syllable_index}" }
 # 		confusing_indices_right.each{|index| character_tag_array[index][1] = "Onset:#{right_syllable_index}" }
 		
 # 	end

	# word = hyphenated_word.split("-").join("")
	# nos = character_tag_array.map{|x| x[1].split(":")[1].to_i }
	# syllabified = []
	# word.size.times do |i|
	# 	syllabified << word[i]			
	# 	syllabified << "-" if nos[i+1] != nos[i]
	# end
	# syllabified.tap(&:pop).join("")
	# syllabified.join
	# # ap syllabified



	# ##Solve the confusing part using HYBRID MOP

 	for confusing_part in confusing_parts
 		left = [] ; right = confusing_part.slice(3,1).first.split("")
 		combinations = []
 		combinations << [left , right]
 		while not right.empty? do
 			left = left.dup
 			right = right.dup
 			left.push(right.shift)
 			combinations << [left , right] 			
 		end

 		max_freq = combinations.map{|combination| frequency_of_onset(combination[1].join()).to_i }.max
 		max_probable_combination = combinations.select{|combination| frequency_of_onset(combination[1].join()).to_i == max_freq }.first

 		left , right = max_probable_combination[0] , max_probable_combination[1]
 		# ap "For confusing_part #{confusing_part}  max probable combination is : #{max_probable_combination}"
 		###############

 		confusing_indices = (confusing_part[0]..confusing_part[1]).to_a
 		confusing_indices_left = confusing_indices.take(left.size)
 		confusing_indices_right = confusing_indices - confusing_indices_left
 		left_syllable_index , right_syllable_index = confusing_part[2].split("-").map(&:to_i)

 		confusing_indices_left.each{|index| character_tag_array[index][1] = "Coda:#{left_syllable_index}" }
 		confusing_indices_right.each{|index| character_tag_array[index][1] = "Onset:#{right_syllable_index}" }
 		
 	end

	word = hyphenated_word.split("-").join("")
	nos = character_tag_array.map{|x| x[1].split(":")[1].to_i }
	syllabified = []
	word.size.times do |i|
		syllabified << word[i]			
		syllabified << "-" if nos[i+1] != nos[i]
	end
	syllabified.tap(&:pop).join("")
	syllabified.join
	# ap syllabified






end


# ap tag(hyphenate("brinksmanship"))