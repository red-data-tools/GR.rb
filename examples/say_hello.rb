# frozen_string_literal: true

# https://github.com/jheinen/GR.jl/tree/master/examples

ENV['GKS_ENCODING'] = 'utf8'

require 'gr'

hello = {
  'Chinese' => '你好世界',
  'Dutch' => 'Hallo wereld',
  'English' => 'Hello world',
  'French' => 'Bonjour monde',
  'German' => 'Hallo Welt',
  'Greek' => 'γειά σου κόσμος',
  'Italian' => 'Ciao mondo',
  'Japanese' => 'こんにちは世界',
  'Korean' => '여보세요 세계',
  'Portuguese' => 'Olá mundo',
  'Russian' => 'Здравствуй, мир',
  'Spanish' => 'Hola mundo'
}

y = 0.9
hello.each do |lang, trans|
  GR.text(0.1, y, lang)
  GR.text(0.4, y, trans)
  y -= 0.072
end
GR.updatews

gets
