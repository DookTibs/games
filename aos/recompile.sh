#!/bin/bash
# coffee -o src/js/ -j aos.js -cw src/coffee/svgUtils.coffee src/coffee/hexDrawer.coffee
coffee -o src/js/ -j aos.js -cw src/coffee/*.coffee
# cat src/coffee/*.coffee | coffee --compile --stdio > -o src/js/aos.js
