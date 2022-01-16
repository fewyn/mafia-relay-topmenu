
boolean have_bookshelf() {
	if(in_bad_moon() || ($strings[Avatar of Boris, Zombie Slayer, Avatar of Sneaky Pete] contains my_path()))
		return false;
	for s from 7213 to 7230  // Tomes, Librams and Grimoires up to Summon Geeky Things
		if(have_skill(to_skill(s)) && (is_unrestricted(s))) // Do I have the skill and can it be used
			return true;
	return false;
}

// Go straight to bookshelf from campground.
string camplink() {
	if(have_bookshelf())
		return 'campground.php?action=bookshelf';
	return "campground.php";
}

// <a target=mainpane href="campground.php">campground</a>
string campground() {

	string camp;
	if(my_path() == "Actually Ed the Undying")
		camp = 'place.php?whichplace=edbase"><span style="font-weight:normal;color:#1975FF">pyramid</span></a>';
	else
		camp = camplink() + '">camp</a>';  // Shorter than "campground"
	
	// Chateau Mantegna
	if(get_property("chateauAvailable") == "true")
		camp += '&nbsp;<a target=mainpane href="place.php?whichplace=chateau">chateau</a>';
	
	// Add Cosmic Kitchen in Jarlsberg
	if(my_path() == "Avatar of Jarlsberg")
		camp += '&nbsp;<a target=mainpane href="shop.php?whichshop=jarl">kitchen</a>';
		
	return camp;
}

// find guild
string guild() {
	if(my_path() == "Nuclear Autumn")
		return "shop.php?whichshop=mutate";
	switch(my_class()) {
	case $class[Seal Clubber]:
	case $class[Turtle Tamer]:
		return "guild.php?guild=f";
	case $class[Disco Bandit]:
	case $class[Accordion Thief]:
		return "guild.php?guild=t";
	case $class[Pastamancer]:
	case $class[Sauceror]:
		return "guild.php?guild=m";
	case $class[Avatar of Boris]:
		return "da.php?place=gate1";
	case $class[Zombie Master]:
		return "campground.php?action=grave";
	case $class[Avatar of Jarlsberg]:
		return "da.php?place=gate2";
	case $class[Avatar of Sneaky Pete]:
		return "da.php?place=gate3";
	case $class[Ed the Undying]:
		return "place.php?whichplace=edbase&action=edbase_book";
	case $class[Cow Puncher]:
	case $class[Beanslinger]:
	case $class[Snake Oiler]:
		// For West of Loathing, ChIT actually creates its own guildhall for the three books. Use that if installed.
		if(svn_exists("mafiachit"))
			return "chit_WestGuild.php";
		// Books are in the same order as the classes. Just add 8937 to convert
		return "inv_use.php?whichitem="+to_string(to_int(my_class()) + 8937)+"&pwd="+my_hash();
	}
	return "town.php";
}

boolean airport_available() {
	boolean have_airport(item charter, string elem) {
		if(is_unrestricted(charter))
			return get_property(elem+"AirportAlways") == "true" || get_property("_"+elem+"AirportToday") == "true";
		return false;
	}
	boolean check_airports() {
		return have_airport($item[airplane charter: Spring Break Beach], "sleaze")
			|| have_airport($item[airplane charter: Conspiracy Island], "spooky")
			|| have_airport($item[airplane charter: Dinseylandfill], "stench")
			|| have_airport($item[airplane charter: That 70s Volcano], "hot")
			|| have_airport($item[airplane charter: The Glaciest], "cold");
	}
	
	if(check_airports())
		return true;
	// If check_airports() is false, a temporary pass might have been used today. Check it once a day.
	if(get_property("_baleTopmenuAirportCheck") != "true") {
		visit_url("place.php?whichplace=airport");
		set_property("_baleTopmenuAirportCheck", "true"); // Only check this once a day!
		return check_airports();
	}
	return false;
}
	
string airport_link() {
	if(airport_available())
		return '&nbsp;<a target=mainpane href="place.php?whichplace=airport">airport</a>';
	return "";
}

// Add link to lair which was removed by NS'15 until after you break the prism.
// Once you've broken the prism, the only reason to go to the lair is to ascend.
void lairlink(buffer results) {
	if(my_level() < 13)
		return;
	if(results.contains_text("place.php?whichplace=nstower")) {
		if(get_property("kingLiberated") == "true")
			results.replace_string('place.php?whichplace=nstower', 'ascend.php');
	} else {
		string island = ">knoll</a>";
		buffer lair;
		lair.append(island);
		lair.append('&nbsp;<a target=mainpane href="');
		if(get_property("kingLiberated") == "true") {
			lair.append("ascend.php");
		} else
			lair.append('place.php?whichplace=nstower');
		lair.append('">lair</a>');
		results.replace_string(island, lair);
	}
}
		
// Add Whitelist to top of right side. Based on bUMRATS, reworked and kerjiggered by Fluxxdog and Bale
// results.addWhitelist("<div style='position:absolute; bottom:0px; right: 0px;'>", "</div></body>", "</body>");
// results.addWhitelist("<div style='position:absolute; bottom:0px; left: 0px;'>", "</div></body>", "</body>");
void addWhitelist(buffer results, string front, string back, string rep) {
	string clanlist = visit_url("clan_signup.php");
	if(index_of(clanlist, "<select name=whichclan>") >= 0 && index_of(clanlist, "<input type=submit class=button value='Go to Clan'>") >= 0) {
		buffer dropdown;
		dropdown.append(front);
		
		dropdown.append("<font size=-1><select style='max-width:104px;' onchange='if (this.selectedIndex>0) { top.mainpane.document.location.href=\"showclan.php?pwd=");
		dropdown.append(my_hash());
		dropdown.append("&action=joinclan&confirm=on&whichclan=\" + this.options[this.selectedIndex].value; this.options[0].selected=true;}'><option>-change clan-</option>");
		dropdown.append(substring(clanlist, index_of(clanlist, "<select name=whichclan>")+23, index_of(clanlist, "<input type=submit class=button value='Go to Clan'>")));  // This is the whitelist
		
		dropdown.append(back);
		results.replace_string(rep, dropdown);
	}
}

string raidlog(int height) {
	return '<a href="clan_raidlogs.php" target="mainpane">'
		  + '<img src="http://images.kingdomofloathing.com/adventureimages/hobofort.gif" height='+height+' alt="Clan Raidlog" title="Clan Raidlog" style="margin:0 0 0 0; border: 0" /></a>';
}

string florist(int height) {
	int true_height = height * 1.36;
	return '<div style="height: '+height+'px; overflow:hidden; margin:0 0 0 0; border:0; bottom: 0px;"><a href="place.php?whichplace=forestvillage&action=fv_friar" target="mainpane">'
			  + '<img src="http://images.kingdomofloathing.com/otherimages/forestvillage/friarcottage.gif" height='+true_height+' alt="Florist Friars" title="Florist Friars" style="margin-top:'+(height-true_height)+'px; border:0" /></a></div>';
}

string calendar = '<a target=_blank href="http://www.noblesse-oblige.org/calendar/">';

void smoon(buffer results) {
	matcher moon_img = create_matcher('<img src="http://images\\.kingdomofloathing\\.com/itemimages/smoon[^>]+>', results);
	while(moon_img.find())
		results.replace_string(moon_img.group(0), calendar + moon_img.group(0) + "</a>");
}

void linkStyle(buffer results) {
	string alt = '<span style="font-weight:normal;color:#1975FF">'; // #049916 would be green possibility
	
	/*****************
	    FIRST ROW	*/
	
	// inventory page option
	results.replace_string('inventory.php">inventory</a>',
	  'inventory.php?which=1">inv</a><a target=mainpane href="inventory.php?which=2">'+alt+'ent</span></a><a target=mainpane href="inventory.php?which=3">ory</a>&nbsp;<a target=mainpane href="inventory.php?which=f-1">recent</a>&nbsp;<a target=mainpane href="inventory.php?which=f0">fav</a>');
	
	// quests page option
	results.replace_string('questlog.php">quests</a>', 'questlog.php?which=1">qu</a><a target=mainpane href="questlog.php?which=4">'+alt+'es</span></a><a target=mainpane href="questlog.php?which=6">ts</a>');
	
	// crafting page option
	results.replace_string('craft.php">crafting</a>', 'craft.php">craft</a><a target=mainpane href="craft.php?mode=discoveries">'+alt+'ing</span></a>');
	
	// add either VIP or sofa link, depending
	if(item_amount($item[Clan VIP Lounge key]) > 0)
		  results.replace_string('clan_hall.php">clan</a>', 'clan_hall.php">clan</a>&nbsp;<a target=mainpane href="clan_viplounge.php">VIP</a>&nbsp;<a target=mainpane href="clan_viplounge.php?whichfloor=2">VIP2</a>');
	else results.replace_string('clan_hall.php">clan</a>', 'clan_hall.php">clan</a>&nbsp;<a target=mainpane href="clan_rumpus.php?action=click&spot=5&furni=3">sofa</a>');
	
	// messages page option
	results.replace_string('messages.php">messages</a>', 'messages.php?box=Inbox">mes</a><a target=mainpane href="messages.php?box=Outbox">'+alt+'sag</span></a><a target=mainpane href="sendmessage.php">es</a>');
	
	/*****************
	    SECOND ROW	*/
	
	// change campground
	results.replace_string('campground.php">campground</a>', campground());
	
	// Add dungeon after mountains
	results.replace_string('mountains</a>&nbsp;', 'mountains</a>&nbsp;<a target=mainpane href="da.php">dungeon</a>&nbsp;');
	
	// add beanstalk, knob, manor, sea around plains. Change sea link to sea floor.
	string plains = '<a target=mainpane href="plains.php">plains</a>';
	buffer plainsMod;
	if(results.contains_text("thesea.php")) {
		results.replace_string("thesea.php", "seafloor.php");
	} else if(available_amount($item[makeshift SCUBA gear]) > 0 || available_amount($item[old SCUBA tank]) > 0)
		plainsMod.append('<a target=mainpane href="seafloor.php">sea</a>&nbsp;');
	plainsMod.append(plains);
	if(my_level() > 4 && my_path() != "Community Service") plainsMod.append('&nbsp;<a target=mainpane href="cobbsknob.php">knob</a>');
	if(my_level() > 9) plainsMod.append('&nbsp;<a target=mainpane href="beanstalk.php">bean</a>');
	if(knoll_available())
		plainsMod.append('&nbsp;<a target=mainpane href="place.php?whichplace=knoll_friendly">knoll</a>');
	else if(gnomads_available())
		plainsMod.append('&nbsp;<a target=mainpane href="gnomes.php">gnome</a>');
	results.replace_string(plains, plainsMod);
	
	// Add link to lair which was removed by NS'15. Once you've broken the prism, the only reason to go to the lair is to ascend.
	results.lairlink();
	
	// Fix link to bugbear mothership
	if(my_path() == "Bugbear Invasion")
		results.replace_string('whichplace=bugbearship_outside', 'whichplace=bugbearship');
	
	/*****************
	    THIRD ROW	*/
	
	// Remove old town link and replace documentation with new set of town links
	string town = '<a target=mainpane href="town.php">town</a>&nbsp;';
	results.replace_string(town, ""); // Remove original town link from results
	string doc = '<a href="#" onClick=\'javascript:window.open("doc.php?topic=home","","height=400,width=550,scrollbars=yes,resizable=yes");\'>documentation</a>';
	int docIndex = index_of(results, doc);
	if(docIndex > 0)
		results.replace(docIndex, docIndex+length(doc),town+'<a target=mainpane href="town_wrong.php">'+alt+'(W&nbsp;</span></a>/<a target=mainpane href="town_right.php">&nbsp;R)</a>'
			+ '&nbsp;<a target=mainpane href="place.php?whichplace=manor1">manor</a>'
			+ '&nbsp;<a target=mainpane href="place.php?whichplace=monorail">monorail</a>'
			+ '&nbsp;<a target=mainpane href="'+guild()+'">guild</a>'
			+ '&nbsp;<a target=mainpane href="shop.php?whichshop=doc">Doc</a>'
			+ '&nbsp;<a target=mainpane href="bordertown.php">border</a>'
			+ '&nbsp;<a target=mainpane href="forestvillage.php">village</a>'
			+ airport_link()
			);
	
	// Replace forum and radio links with a link to the wiki
	results.replace_string('&nbsp;<a href="#" onClick=\'javascript:window.open("http://www.kingdomofloathing.com/radio.php","");\'>radio</a>', 
		'&nbsp;<a target=_blank href="http://kol.coldfront.net/thekolwiki/index.php/Main_Page">wiki</a>');
	
	// Change pvp to PvP
	results.replace_string(">pvp<", ">PvP<");
	
	// Jick removed the forums from Community everyplace else in the game. We need a forum link and since store is in Community we don't need the Store in two places
	results.replace_string('<a target=_blank href="http://store.asymmetric.net/">store</a>', '<a target=_blank href="http://forums.kingdomofloathing.com/vb/index.php">forums</a>');
	
	/*****************
	   OTHER STUFF	*/
	
	// character image link to public charsheet
	results.replace_string('<td align=center valign=center><img',
	  '<td align=center valign=center><a target=mainpane href="showplayer.php?who='+my_id()+'"><img title="View Public Charsheet" style="border:0"');
	results.replace_string('smallleftswordguy.gif" width=33 height=40>', 'leftswordguy.gif" width=33 height=40></a>');
	
	// Increase font size
	results.replace_string('tiny { font-size: 9px; }', 'tiny { font-size: 12px; }');
 	
	// Add a few images to the left...
	string table = '<table cellpadding=0 ><tr>';
	int lastTr = last_index_of( results , table );
	if(lastTr > 0) {
		lastTr += length(table);

		// add image link to basement logs
		results.replace(lastTr, lastTr, '<td>'+raidlog(45)+'</td>');
		int margin = 50;
		
		// Add image link to the Florist
		if(florist_available()) {
			results.replace( lastTr , lastTr , '<td>'+florist(45)+'</td>');
			margin += 50;
		}
		
		// Add a margin on the right to prevent the moons vanishing under the drop-downs
		results.replace_string(table, '<center><table style="margin-right:'+margin+'px" cellpadding=0>');
	}

	// Make moons a link to http://www.noblesse-oblige.org/calendar/
	int moons = index_of(results, '<table cellpadding=0 id="themoons">');
	if(moons > 0) {
		results.replace(moons, moons, calendar);
		moons = index_of(results, '</table>', moons) + length('</table>');
		results.replace(moons, moons, '</a>');
	}
	
	// Kill a lot of line breaks in the menu
	results = results.replace_string("</a> <a", "</a>&nbsp;<a")
		.replace_string("log out", "log&nbsp;out")
		.replace_string("report bug", "report&nbsp;bug");
	
	// Add clan whitelist drop-down
	if(get_property("relayAddsQuickScripts") == "false")
		results.addWhitelist("cellspacing=0><tr><td>", "</td></tr><tr>", "cellspacing=0><tr>");
	else { // If the script menu is present it is a tiny bit more complicated. Also, fix formatting of script menu.
		results.addWhitelist("<div style='position:absolute; top:0px; left: 0px;'>", "</div></body>", "</body>");
		results.replace_string('<form name="gcli">', '<form name="gcli" style="margin: 0px; padding: 0px; display: inline">');
	}

}

void iconStyle(buffer results) {
	// Make sure that this isn't done twice, if redirected from awesomemenu
	if(results.contains_text(calendar))
		return;
		
	// Make moons a link to http://www.noblesse-oblige.org/calendar/
	results.smoon();
	
	// Add clan whitelist drop-down
	results.addWhitelist("cellspacing=0><tr><td>", "</td></tr><tr>", "cellspacing=0><tr>");
	results.replace_string("<div style='position: absolute; z-index: 5; top: 40px; right: 0px; border-width: 1px color:#000000'>", "<div style='position: absolute; z-index: 5; top: 30px; right: 0px; border-width: 1px color:#000000'>");
	
}

void dropdownStyle(buffer results) {
	// change campground
	results.replace_string('campground.php', camplink());
	//Guild
	results.replace_string('<option value="guild.php">','<option value="'+guild()+'">');
	
	// Add a few images to the left...
	string table = '<table cellpadding=0><tr>';
	int lastTr = last_index_of( results , table );
	if(lastTr > 0) {
		lastTr += length(table);

		// add image link to basement logs
		results.replace(lastTr, lastTr, '<td>'+raidlog(28)+'</td>');
		int margin = 50;
		
		// Add image link to the Florist
		if(florist_available()) {
			results.replace( lastTr , lastTr , '<td>'+florist(28)+'</td>');
			margin += 50;
		}
		
		// Add a margin on the right to prevent the moons vanishing under the drop-downs
		results.replace_string(table, '<center><table style="margin-right:'+margin+'px" cellpadding=0>');
	}

	// Make moons a link to http://www.noblesse-oblige.org/calendar/
	int moons = index_of(results, '<b>Moons: </b>');
	if(moons > 0)
		results.replace_string('<b>Moons: </b>', calendar+ 'Moons:</a>');
	results.smoon();
	
	// Add clan whitelist drop-down
	results.addWhitelist("<div style='position:absolute; top:4px; left: 0px;'>", "</div></body>", "</body>");
	
	// Fix formatting of script menu.
	if(get_property("relayAddsQuickScripts") == "true") {
		results.replace_string('<form name="gcli">', '<form name="gcli" style="margin: 0px; padding: 0px; display: inline">');
		results.replace_string('</form></td></tr><tr>', '</form></td>');
	}
	
	// Add link to lair which was removed by NS'15.
	if(my_level() >= 13 && !results.contains_text("lair.php")) // KoL actually does add the link after breaking the pyramid
		results.replace_string('Nearby Plains</a>', 'Nearby Plains</option><option value="lair.php">Sorceress\' Lair</option>');
	// Once you've broken the prism, the only reason to go to the lair is to ascend.
	if(get_property("kingLiberated") == "true")
		results.replace_string('lair.php', 'ascend.php');

}

void main() {
	buffer results;
	results.append(visit_url());
	
	// Check for topmenu style
	if(results.contains_text("smallleftswordguy.gif"))
		results.linkStyle();
	else if(results.contains_text("awesomemenu.php"))
		results.iconStyle();
	else
		results.dropdownStyle();
	
	results.write();
}