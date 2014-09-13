// Generated by CoffeeScript 1.8.0
(function() {
  window.HexDrawer = (function() {
    HexDrawer.prototype.SIDE_PADDING = 1;

    function HexDrawer(snapCanvasId) {
      this.snapCanvasId = snapCanvasId;
      console.log("now snap canvas is [" + this.snapCanvasId + "]");
      this.snapCanvas = Snap("#" + this.snapCanvasId);
      this.jqCanvas = $("#" + this.snapCanvasId);
    }

    HexDrawer.prototype.generateHexPoints = function(center, size) {
      var angle, i, loopX, loopY, rv, _i;
      rv = [];
      for (i = _i = 0; _i <= 5; i = ++_i) {
        angle = 2 * Math.PI / 6 * i;
        loopX = center.x + size * Math.cos(angle);
        loopY = center.y + size * Math.sin(angle);
        rv.push({
          x: loopX,
          y: loopY
        });
      }
      return rv;
    };

    HexDrawer.prototype.createPathFromPoints = function(pts, closePath) {
      var i, pt, rv, _i, _len;
      if (closePath == null) {
        closePath = true;
      }
      if (closePath) {
        pts.push(pts[0]);
      }
      rv = "";
      for (i = _i = 0, _len = pts.length; _i < _len; i = ++_i) {
        pt = pts[i];
        rv += i === 0 ? "M" : "L";
        rv += pt.x + " " + pt.y;
      }
      return rv;
    };

    HexDrawer.prototype.drawCircle = function(center, radius, className) {
      var c;
      c = this.snapCanvas.circle(center.x, center.y, radius);
      return c.attr({
        "class": className
      });
    };

    HexDrawer.prototype.drawHex = function(center, size, className) {
      var hex, path, pts;
      pts = this.generateHexPoints(center, size);
      path = this.createPathFromPoints(pts);
      hex = this.snapCanvas.path(path);
      hex.attr({
        "class": className
      });
      return hex;
    };

    HexDrawer.prototype.sizeToFit = function(rows, cols) {
      var hVal, vVal, vValTmp;
      console.log("size hexes to fit - dimensions are [" + this.jqCanvas.width() + "] x [" + this.jqCanvas.height() + "]");
      hVal = (this.jqCanvas.width() - (this.SIDE_PADDING * 2)) / ((.75 * (cols - 1)) + 1);
      if (cols === 1) {
        vValTmp = (this.jqCanvas.height() - (this.SIDE_PADDING * 2)) / (.5 * rows);
      } else {
        vValTmp = (this.jqCanvas.height() - (this.SIDE_PADDING * 2)) / ((.5 * rows) + .25);
      }
      vVal = vValTmp / (Math.sqrt(3));
      return Math.min(hVal, vVal) / 2;
    };

    HexDrawer.prototype.drawHexGrid = function(rows, cols, hexSize, data, defaultHexClass) {
      var c, centerX, centerY, classForHex, d, hex, hexHeight, hexWidth, horizDistance, lookupKey, r, xOffset, yOffset, _i, _ref, _results;
      if (defaultHexClass == null) {
        defaultHexClass = "basicHex";
      }
      if (hexSize === -1) {
        hexSize = this.sizeToFit(rows, cols);
      }
      hexWidth = hexSize * 2;
      horizDistance = 3 / 4 * hexWidth;
      hexHeight = Math.sqrt(3) / 2 * hexWidth;
      xOffset = hexSize + this.SIDE_PADDING;
      yOffset = hexHeight / 2 + this.SIDE_PADDING;
      _results = [];
      for (r = _i = 0, _ref = rows - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; r = 0 <= _ref ? ++_i : --_i) {
        _results.push((function() {
          var _j, _ref1, _results1;
          _results1 = [];
          for (c = _j = 0, _ref1 = cols - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; c = 0 <= _ref1 ? ++_j : --_j) {
            centerX = xOffset + (c * horizDistance);
            centerY = yOffset + (r * hexHeight) + (c % 2 === 1 ? hexHeight / 2 : 0);
            classForHex = defaultHexClass;
            lookupKey = "" + c + "," + r;
            d = data[lookupKey];
            if (d !== void 0 && d["class"] !== void 0) {
              classForHex = d["class"];
            }
            hex = this.drawHex({
              x: centerX,
              y: centerY
            }, hexSize, classForHex);
            if (d !== void 0 && d.town !== void 0) {
              this.drawCircle({
                x: centerX,
                y: centerY
              }, hexSize * .5, "town");
            }
            if (d !== void 0 && d.city !== void 0) {
              _results1.push(hex.attr({
                "class": "city city" + d.city.color
              }));
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    return HexDrawer;

  })();

}).call(this);
