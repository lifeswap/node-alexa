#!/usr/bin/env zsh

#DEBUG='*' \
NODE_PATH=`pwd` ENV=TEST \
	./node_modules/.bin/mocha \
    --timeout 1000 \
		--compilers coffee:coffee-script \
		--reporter progress \
		--require should \
    test/func/*.coffee \
