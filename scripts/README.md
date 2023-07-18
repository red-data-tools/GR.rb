# Scripts for Maintaining GR.rb

Scripts to check for updates in gr.h and gr3.h and grm header files.
Run these scripts from the root of the repository. 

```sh
bundle install # colorize and diffy

# Show differences between gr.rb and gr.h
bundle exec scripts/gr_diff.rb

# Show differences between gr3.rb and gr3.h
bundle exec scripts/gr3_diff.rb

# show differences between grm.rb and grm header files
bundle exec scripts/grm_diff.rb
```
