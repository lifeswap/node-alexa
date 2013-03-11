doc:
	docco lib/*.coffee

unit:
	NODE_PATH=`pwd` \
	scripts/unit.zsh

func:
	NODE_PATH=`pwd` \
	scripts/func.zsh

.PHONY: doc
