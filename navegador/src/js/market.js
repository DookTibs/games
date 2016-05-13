var GOOD_SUGAR = "sugar";
var GOOD_GOLD = "gold";
var GOOD_SPICE = "spice";

function Market() {
    this.sugarPos= 7;
	this.goldPos = 3;
	this.spicePos = 1;

	this.getPrice = function(good, isFactoryOption) {
		var pos = -1;
		var increaser = 0;
		if (good == GOOD_SUGAR) {
			pos = this.sugarPos;
		} else if (good == GOOD_GOLD) {
			pos = this.goldPos;
			increaser = 10;
		} else if (good == GOOD_SPICE) {
			pos = this.spicePos;
			increaser = 20;
		}

		if (pos == -1) {
			console.log("invalid good type [" + good + "] passed in...");
		} else {
			if (isFactoryOption) {
				if (pos <= 2) {
					return 60;
				} else if (pos <= 4) {
					return 50;
				} else if (pos <= 6) {
					return 40;
				} else if (pos <= 8) {
					return 30;
				} else if (pos <= 10) {
					return 20;
				}
			} else {
				if (pos <= 2) {
					return 20 + increaser;
				} else if (pos <= 4) {
					return 30 + increaser;
				} else if (pos <= 6) {
					return 40 + increaser;
				} else if (pos <= 8) {
					return 50 + increaser;
				} else if (pos <= 10) {
					return 60 + increaser;
				}
			}
		}
	};

	this.moveGoodPosition = function(good, movement) {
		var pos = -1;
		if (good == GOOD_SUGAR) {
			pos = this.sugarPos;
		} else if (good == GOOD_GOLD) {
			pos = this.goldPos;
		} else if (good == GOOD_SPICE) {
			pos = this.spicePos;
		}

		if (pos != -1) {
			pos += movement;

			if (pos > 10) { pos = 10; }
			if (pos < 1) { pos = 1; }
		}

		if (good == GOOD_SUGAR) {
			this.sugarPos = pos;
		} else if (good == GOOD_GOLD) {
			this.goldPos = pos;
		} else if (good == GOOD_SPICE) {
			this.spicePos = pos;
		}
	};

	this.sellGoodsWithColonies = function(good, amount) {
		var currentPrice = this.getPrice(good, false);
		this.moveGoodPosition(good, -1 * amount);
		return amount * currentPrice;
	};

	this.processGoodsWithFactories = function(good, amount) {
		var currentPrice = this.getPrice(good, true);
		this.moveGoodPosition(good, amount);
		return amount * currentPrice;
	};
}
Market.prototype = { constructor: Market }
