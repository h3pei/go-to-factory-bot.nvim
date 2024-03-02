.PHONY: test

test:
	nvim --headless --noplugin -u tests/init.lua -c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/init.lua', sequential = true }"
