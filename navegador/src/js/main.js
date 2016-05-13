function startup() {
	console.log("do it!!!");

	// test the market
	var m = new Market();
	console.log("price of sugar is [" + m.getPrice(GOOD_SUGAR, false) + "]/[" + m.getPrice(GOOD_SUGAR, true) + "]");
	console.log("price of gold is [" + m.getPrice(GOOD_GOLD, false) + "]/[" + m.getPrice(GOOD_GOLD, true) + "]");
	console.log("price of spice is [" + m.getPrice(GOOD_SPICE, false) + "]/[" + m.getPrice(GOOD_SPICE, true) + "]");

	var sugarProfit = m.sellGoodsWithColonies(GOOD_SUGAR, 10);
	var goldProfit = m.processGoodsWithFactories(GOOD_GOLD, 3);
	console.log("sold 10 sugars from colonies, making [" + sugarProfit + "] bucks");
	console.log("processed 3 gold from factories, making [" + goldProfit + "] bucks");

	console.log("price of sugar is [" + m.getPrice(GOOD_SUGAR, false) + "]/[" + m.getPrice(GOOD_SUGAR, true) + "]");
	console.log("price of gold is [" + m.getPrice(GOOD_GOLD, false) + "]/[" + m.getPrice(GOOD_GOLD, true) + "]");
	console.log("price of spice is [" + m.getPrice(GOOD_SPICE, false) + "]/[" + m.getPrice(GOOD_SPICE, true) + "]");

	// 9 sugar, 11 gold, 13 spice
	var colonies = [];
	/*
	var a1 = new Colony(GOOD_SUGAR, 80);
	var a1 = new Colony(GOOD_SUGAR, 90);
	var a1 = new Colony(GOOD_SUGAR, 100);
	var a1 = new Colony(GOOD_SUGAR, 110);
	var a1 = new Colony(GOOD_SUGAR, 120);

	var b1 = new Colony(GOOD_GOLD, 100);
	var b1 = new Colony(GOOD_GOLD, 110);
	var b1 = new Colony(GOOD_GOLD, 120);
	var b1 = new Colony(GOOD_GOLD, 130);
	var b1 = new Colony(GOOD_GOLD, 140);
	var b1 = new Colony(GOOD_GOLD, 150);

	var c1 = new Colony(GOOD_SPICE, 90);
	var c1 = new Colony(GOOD_SPICE, 100);
	var c1 = new Colony(GOOD_SPICE, 110);
	var c1 = new Colony(GOOD_SPICE, 120);
	var c1 = new Colony(GOOD_SPICE, 130);
	var c1 = new Colony(GOOD_SPICE, 140);
	var c1 = new Colony(GOOD_SPICE, 150);
	var c1 = new Colony(GOOD_SPICE, 160);
	var c1 = new Colony(GOOD_SPICE, 170);
	var c1 = new Colony(GOOD_SPICE, 180);
	*/
}
