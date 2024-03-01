.PHONY: test

test:
	nvim --headless -c "PlenaryBustedDirectory specs/ { minimal_init = 'specs/init.lua', sequential = true }"
