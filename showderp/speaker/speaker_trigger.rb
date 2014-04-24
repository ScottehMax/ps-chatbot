require "./showderp/speaker/markovchains.rb"
require 'json'

Trigger.new do |t|
  t[:id] = 'speaker'
  
  t.match { |info|
    (info[:where] == 'c') && info[:what]
  }
  
  chain_path = './showderp/speaker/chain.json'
  if !File.exist?(chain_path)
    File.open(chain_path, 'w') do |f| 
      f.puts '{}'
    end
  end
  
  print 'Loading phrases I know...  '
  chain = Markov.chain_from_json(File.open(chain_path).read)
  puts 'done.'
  
  t.act do |info|
    text = info[:result]
    
    name = $login[:name]
    
    if text[0..name.size].downcase == "#{name.downcase},"
      next if info[:who] == $login[:name]
    
      words = text[name.size..-1].split(' ')
      seed = nil
      
      chain.nodes.each do |keys, values|
        if words.reverse.any? { |word| keys.index(word) }
          seed = keys
          break
        end
      end
      
      info[:respond].call("(#{info[:who]}) #{chain.generate(10, seed).join(' ')}.".capitalize)
    else
      chain.add_words(text)
    end
  end
  
  t.exit do
    puts 'Saving phrases I know...'
    File.open(chain_path, 'w') do |f|
      f.puts JSON.dump(chain.nodes)
    end
  end
end