doc:
	docco lib/*.coffee

unit:
	scripts/unit.zsh

func:
	scripts/func.zsh

.PHONY: doc
