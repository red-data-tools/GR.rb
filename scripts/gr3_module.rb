gr3_h_code = `#{File.expand_path('gr3_h.sh', __dir__)}`
gr3_m_code = File.read(File.expand_path('../lib/gr3.rb', __dir__))

gr3_allfunc = gr3_h_code.scan(/(?<= gr3_)[0-9a-zA-Z_]+/).to_a - %w[coord_t triangle_t]
gr3_comment = gr3_m_code.scan(/(?<=# @!method )[0-9a-zA-Z_]+/).to_a
gr3_defined = gr3_m_code.scan(/(?<= def )[0-9a-zA-Z_]+/).to_a

p(gr3_comment & gr3_defined)

p gr3_comment

p gr3_defined

p gr3_allfunc - gr3_comment - gr3_defined
