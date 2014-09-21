#!/bin/bash
# coffee -o src/js/ -j aos.js -cw src/coffee/svgUtils.coffee src/coffee/hexDrawer.coffee
coffee -o src/js/ -j aos.js -cw src/coffee/*.coffee
# coffee -o src/js/ -j aos.js -cw src/coffee/board.coffee src/coffee/defaultController.coffee src/coffee/prController.coffee src/coffee/hexGameBoard.coffee src/coffee/svgUtils.coffee
# cat src/coffee/*.coffee | coffee --compile --stdio > -o src/js/aos.js
