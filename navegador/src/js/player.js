// represents game state of a single player
function Player(name) {
    this.name = name;
	this.colonies = [];
	this.money = 200;
	this.explorers = 0;
	this.shipyards = 1; // actual ships are stored elsewhere
	this.churches = 1;
	this.sugarFactories = 0;
	this.goldFactories = 0;
	this.spiceFactories = 0;
	this.workers = 3;
}
Player.prototype = { constructor: Player }
