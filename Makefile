.PHONY: test

test:
	nvim --headless --noplugin -u specs/init.lua -c "PlenaryBustedDirectory specs/ { minimal_init = 'specs/init.lua', sequential = true }"
