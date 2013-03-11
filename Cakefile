{spawn} = require 'child_process'

task 'build', 'Build lib/ from src/', ->
  coffee = spawn 'node_modules/.bin/coffee', ['-c', '-o', 'lib', 'src']
  coffee.stdout.on 'data', (data) ->
    console.log data.toString().trim()

task 'watch', 'Build lib/ from src/ and  watch for changes', ->
  coffee = spawn 'node_modules/.bin/coffee', ['-c','-w', '-o', 'lib', 'src']
  coffee.stdout.on 'data', (data) ->
    console.log data.toString().trim()

task 'clean', 'Remove lib/', ->
  rm = spawn 'rm', ['-rf', 'lib']
  rm.stdout.on 'data', (data) ->
    console.log data.toString().trim()
