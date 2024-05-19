V_CONF += picorv32_default.cells picorv32_muldiv.cells picorv32_muldivfast.cells

V_IMPL = picorv32.v

all: $(V_CONF)

# config
# -q is quiet
SYNTH_EXEC	= yosys
SYNTH_SCR	= synth_ice40
SYNTH_OPTS	= -q
#
CELLS_EXEC  = ../cells.py


# synthesize
.PRECIOUS: %.hw.json
%.hw.json: %.v
	@$(SYNTH_EXEC) -p "$(SYNTH_SCR) -top $(basename $<) -json $@" $(SYNTH_OPTS) $< $(V_IMPL)

%.cells: %.hw.json
	@echo -n "$(basename $@): "
	@$(CELLS_EXEC) $< $(basename $@) > $@
	@tail -n1 $@

clean:
	@rm -f *.cells *.hw.json
