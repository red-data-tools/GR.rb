gr_h_code = `#{File.expand_path('gr_h.sh', __dir__)}`
gr_m_code = File.read(File.expand_path('../lib/gr.rb', __dir__))

gr_allfunc = gr_h_code.scan(/(?<= gr_)[0-9a-zA-Z_]+/).to_a
gr_comment = gr_m_code.scan(/(?<=# @!method )[0-9a-zA-Z_]+/).to_a
gr_defined = gr_m_code.scan(/(?<= def )[0-9a-zA-Z_]+/).to_a

raise unless (gr_comment & gr_defined).empty?

p gr_comment

p gr_defined

p gr_allfunc - gr_comment - gr_defined
