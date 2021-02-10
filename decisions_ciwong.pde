import java.util.Set;
import java.util.Iterator;
import java.util.*; 
import java.lang.*; 
import java.io.*; 

//JSON File
String json_file_name = "map.json";

// Coordinates Derived From JSON File
int[] knight_pos;
int[] castle;
int[] tar_pit;
int[] tavern;
int[] tree;
int[] cave;
int[] forge;
ArrayList< ArrayList<Integer> > obstacles;

// Other values derived from JSON File
int kings_gold;
KeyCharacter King;
KeyCharacter Rameses;
KeyCharacter LadyLupa;
KeyCharacter TreeSpirit;
KeyCharacter Innkeeper;
KeyCharacter Blacksmith;
ArrayList<KeyCharacter> characters;

// Inventory
Inventory inv;

// Coordinates Derived From Mouse Click
int[] target_pos;

// Indiction Of Unfinished Path To Follow
boolean unfinished;

// Path To Follow
ArrayList< int[] > path;

// Index In The Path 
int index;

// Ramses Fought
boolean done;

/** 
 *  Sets Up Global Variables & Canvas Size
 */
void setup() {
  
  // Set Up Canvas
  size(640, 480);
   
  // Load Json Data
  JSONObject json = loadJSONObject(json_file_name);
  
  // Load Data For Knight
  JSONArray knight_start = json.getJSONArray("knight_start"); // knight start position
  this.knight_pos = new int[2];
  this.knight_pos[0] = knight_start.getInt(0);
  this.knight_pos[1] = knight_start.getInt(1);
  
  // Load King's Gold
  this.kings_gold = json.getInt("greet_king");
  
  // Load Data For Key Locations
  JSONObject key_locations = json.getJSONObject("key_locations");
  JSONArray castle = key_locations.getJSONArray("castle"); // castle position
  this.castle = new int[2];
  this.castle[0] = castle.getInt(0);
  this.castle[1] = castle.getInt(1);

  JSONArray tar_pit = key_locations.getJSONArray("tar_pit"); // tar pit position
  this.tar_pit = new int[2];
  this.tar_pit[0] = tar_pit.getInt(0);
  this.tar_pit[1] = tar_pit.getInt(1);

  JSONArray tavern = key_locations.getJSONArray("tavern"); // tavern position
  this.tavern = new int[2];
  this.tavern[0] = tavern.getInt(0);
  this.tavern[1] = tavern.getInt(1);

  JSONArray tree = key_locations.getJSONArray("tree"); // tree position
  this.tree = new int[2];
  this.tree[0] = tree.getInt(0);
  this.tree[1] = tree.getInt(1);

  JSONArray cave = key_locations.getJSONArray("cave"); // cave position
  this.cave = new int[2];
  this.cave[0] = cave.getInt(0);
  this.cave[1] = cave.getInt(1);

  JSONArray forge = key_locations.getJSONArray("forge"); // forge position
  this.forge = new int[2];
  this.forge[0] = forge.getInt(0);
  this.forge[1] = forge.getInt(1);
  
  // Load Key Character Wants & Services
  King = new KeyCharacter("King");
  Rameses = new KeyCharacter("Ramses");
  LadyLupa = new KeyCharacter("Lady Lupa");
  TreeSpirit = new KeyCharacter("Tree Spirit");
  Innkeeper = new KeyCharacter("Innkeeper");
  Blacksmith = new KeyCharacter("Blacksmith");
  JSONObject state_of_world = json.getJSONObject("state_of_world"); 
  JSONArray has = state_of_world.getJSONArray("Has"); 
  for ( int i = 0; i < has.size(); i++ ) {
    if ( has.getJSONArray(i).getString(0).equals("Blacksmith") ) {
      Blacksmith.services.add( has.getJSONArray(i).getString(1) );
    } else if ( has.getJSONArray(i).getString(0).equals("Lady Lupa") ) {
      LadyLupa.services.add( has.getJSONArray(i).getString(1) );
    } else if ( has.getJSONArray(i).getString(0).equals("Innkeeper") ) {
      Innkeeper.services.add( has.getJSONArray(i).getString(1) );
    } else if ( has.getJSONArray(i).getString(0).equals("Tree Spirit") ) {
      TreeSpirit.services.add( has.getJSONArray(i).getString(1) );
    }  
  }  

  JSONArray wants = state_of_world.getJSONArray("Wants");

  for ( int i = 0; i < wants.size(); i++ ) {
    if ( wants.getJSONArray(i).getString(0).equals("Blacksmith") ) {
      Blacksmith.wants.add( wants.getJSONArray(i).getString(1) );
    } else if ( wants.getJSONArray(i).getString(0).equals("Lady Lupa") ) {
      LadyLupa.wants.add( wants.getJSONArray(i).getString(1) );
    } else if ( wants.getJSONArray(i).getString(0).equals("Innkeeper") ) {
      Innkeeper.wants.add( wants.getJSONArray(i).getString(1) );
    } else if ( wants.getJSONArray(i).getString(0).equals("Tree Spirit") ) {
      TreeSpirit.wants.add( wants.getJSONArray(i).getString(1) );
    }  
  }  
  
  // Add Characters To List
  characters = new ArrayList<KeyCharacter>();
  characters.add(this.Blacksmith);
  characters.add(this.LadyLupa);
  characters.add(this.Innkeeper);
  characters.add(this.TreeSpirit);
 
  // Load Data For Obstacles
  this.obstacles = new ArrayList< ArrayList<Integer> >();
  JSONObject obstacles = json.getJSONObject("obstacles");
  Set keys = obstacles.keys();
  Iterator<String> it = keys.iterator();
  while( it.hasNext() ) {
    String key_string = it.next();
    // A List Of Coordinates For A Particular  Obstacle
    JSONArray coord_list = obstacles.getJSONArray(key_string); 
    // An Array To Edventually Be Added To The 2D Array "obstacles"
    ArrayList<Integer> temp_array =  new ArrayList<Integer>();
    for ( int i = 0; i < coord_list.size(); i++ ) {
      // The Coordinates From A List Of Coordinates
      JSONArray coord = coord_list.getJSONArray(i);
      temp_array.add( coord.getInt(0) ); 
      temp_array.add( coord.getInt(1) );
    }
    this.obstacles.add(temp_array);   
  }  

  // Inventory Set Up
  this.inv = new Inventory();
  
  // Boolean States Knight Has Not Defeated Rameses
  this.done = false;
  
  // Set Mouse Click / Target Variables To (0,0) For Now
  this.target_pos = new int[2];
  this.target_pos[0] = 0;
  this.target_pos[1] = 0;
  
  // Sets The Boolean For Whether The Knight Has An Unfinished Path To Follow
  this.unfinished = false;
  
  // Initializes The Path ArrayList
  this.path = new ArrayList< int[] >();
  
  // Sets The Index In The Path We Need To Follow To 0
  this.index = 0;
  
}  

/**
 * Draws Items Into The World
 */
void draw() {
  
  // Draw The Background
  background(0);
  
  // Draw Obstacles
  draw_obstacles();
  
  // Draw Key Locations
  draw_castle( this.castle[0], this.castle[1] );
  draw_tar_pit( this.tar_pit[0], this.tar_pit[1] );
  draw_tavern( this.tavern[0], this.tavern[1] );
  draw_tree( this.tree[0], this.tree[1] );
  draw_cave( this.cave[0], this.cave[1] );
  draw_forge( this.forge[0], this.forge[1] );
  
  // Draw Knight 
  draw_knight( this.knight_pos[0], this.knight_pos[1] );
  
  // Update
  update();
}

/**
 * Updates The Knight To Follow A Path If There Is A Path To Follow.
 * Otherwise, The Knight Must Make A Decision.
 */
void update() {
  if ( this.unfinished == true ) {
    if ( index < path.size() ) {
      knight_pos[0] = path.get(index)[0];
      knight_pos[1] = path.get(index)[1];
      index++;
    } else {
      this.unfinished = false;
      delay(500);
    }  
  } else if ( !done ) {
    make_decision();
  }  
}  

/**
 * The Knight Must Make A Decision
 */
void make_decision() {
  
  // Priority 0 - Does The Knight Have Gold? 
  // If Not, Get Gold.
  if ( inv.gold == 0 ) {
    getGold();
    return;
  } 
  
  // Priority 1 - Does The Knight Have A Weapon That Can Defeat Rameses?
  // If So, Go Defeat Ramsus.
  else if ( inv.fenrir == 1 || inv.poisonedSword >= 1 || inv.fire >= 1 ) {
    fightRameses();
    return;
  }  
  
  // Priority 2A - Does The Knight Have Fenrir's Owner's Desire?
  // If So, Exchange Items And Get Fenrir.
  KeyCharacter fenrirOwner = getFenrirOwner();
  if ( fenrirOwner != null ) {
    for ( int i = 0; i < fenrirOwner.wants.size(); i++ ) {
      if ( inv.contains( fenrirOwner.wants.get(i) )) {
        ExchangeWithCharacter(fenrirOwner.name, fenrirOwner.wants.get(i), "Fenrir" );
        return;
      } 
    }  
  } 
   
  // Priority 2B - Does The Knight Have The Means To Craft Fire Or A 
  // Poisoned Sword?
  // If So, Craft The Weapon. 
  if ( inv.contains("Ale") && inv.contains("Wood") ) {
    // Can "Use" Ale & Wood Together To Create Fire
    CombineItems("Ale", "Wood");
    return;
  } else if ( inv.contains("Ale") && inv.contains("Axe") ) {
    // Can "Use" Axe On Tree Spirit To Get Wood
    UseItemOnCharacter("Axe", "Tree Spirit");
    return;
  } else if ( inv.contains("Sword") && inv.contains("Wolfsbane") ) {
    // Can "Use" Sword & Wolfsbane Together To Create Poisoned Sword
    CombineItems("Sword", "Wolfsbane");
    return;
  } else if ( inv.contains("Blade") && inv.contains("Wood") && inv.contains("Wolfsbane") ) {
    // Can "Use" Blade & Wood Together To Create Sword
    CombineItems("Blade", "Wood");
    return;
  } else if ( inv.contains("Blade") && inv.contains("Axe") && inv.contains("Wolfsbane") ) {
    // Can "Use" Axe On Tree Spirit To Get Wood
    UseItemOnCharacter("Axe", "Tree Spirit");
    return;
  }
  
  // Priority C - Does Character Have Means To Get Missing Key Item ( Axe, Blade, Wolfsbane, Ale, Owner
  // Of Fernir's Desire )
  if ( fenrirOwner != null ) {
    for ( int i = 0; i < fenrirOwner.wants.size(); i++ ) {        
        KeyCharacter itemHolder = getOwnerOf( fenrirOwner.wants.get(i) );
        if ( itemHolder != null ) {
          for ( int j = 0; j < itemHolder.wants.size(); j++ ) {
            if ( inv.contains( itemHolder.wants.get(j) )) {
              ExchangeWithCharacter( itemHolder.name, itemHolder.wants.get(j), fenrirOwner.wants.get(i) );
              return;
            }
          }  
        }
         
    }      
  } 
  if ( !inv.contains("Axe") && !inv.contains("Wood")) {
    KeyCharacter itemHolder = getOwnerOf("Axe");
    if ( itemHolder != null ) {
      for ( int i = 0; i < itemHolder.wants.size(); i++ ) {
        if ( inv.contains( itemHolder.wants.get(i) )) {
        ExchangeWithCharacter( itemHolder.name, itemHolder.wants.get(i), "Axe" );
        return;
        }
      }  
    }
  } 
  if ( !inv.contains("Blade") ) {
    KeyCharacter itemHolder = getOwnerOf("Blade");
    if ( itemHolder != null ) {
      for ( int i = 0; i < itemHolder.wants.size(); i++ ) {
        if ( inv.contains( itemHolder.wants.get(i) )) {
        ExchangeWithCharacter( itemHolder.name, itemHolder.wants.get(i), "Blade" );
        return;
        }
      }  
    }
  } 
  if ( !inv.contains("Wolfsbane") ) {
    KeyCharacter itemHolder = getOwnerOf("Wolfsbane");
    if ( itemHolder != null ) {
      for ( int i = 0; i < itemHolder.wants.size(); i++ ) {
        if ( inv.contains( itemHolder.wants.get(i) )) {
            ExchangeWithCharacter( itemHolder.name, itemHolder.wants.get(i), "Wolfsbane" );
            return;
        }
      } 
    }
  } 
  if ( !inv.contains("Ale") ) {
    KeyCharacter itemHolder = getOwnerOf("Ale");
    if ( itemHolder != null ) {
      for ( int i = 0; i < itemHolder.wants.size(); i++ ) {
        if ( inv.contains( itemHolder.wants.get(i) )) {
        ExchangeWithCharacter( itemHolder.name, itemHolder.wants.get(i), "Ale" );
        return;
        }
      }  
    }
  } 

  
  // Priority D - Is Character Missing Any Other Items? Do They Have The Means To Get Them?
  if ( !inv.contains("Water") ) {
    KeyCharacter itemHolder = getOwnerOf("Water");
    if ( itemHolder != null ) {
      for ( int i = 0; i < itemHolder.wants.size(); i++ ) {
        if ( inv.contains( itemHolder.wants.get(i) )) {
        ExchangeWithCharacter( itemHolder.name, itemHolder.wants.get(i), "Water" );
        return;
        }
      }  
    }
  } 
  
}  

/**
 * Returns The Key Character That Own Fenrir.
 */
public KeyCharacter getFenrirOwner() {
  for ( int i = 0; i < characters.size(); i++ ) {
    if ( characters.get(i).hasService("Fenrir") ) {
      return characters.get(i);
    }  
  }
  return null;
} 

public KeyCharacter getOwnerOf( String item ) {
    for ( int i = 0; i < characters.size(); i++ ) {
    if ( characters.get(i).hasService(item) ) {
      return characters.get(i);
    }  
  }
  return null;
}

  

/**
 * Move Knight To Castle & Get Gold.
 */
public void getGold() {
  
  // If The Knight Doesn't Have Gold
  if ( inv.gold == 0 ) {
    // And Is Not In The Castle
    if ( castle[0] > knight_pos[0] + 2 || castle[0] < knight_pos[0] - 2 || castle[1] > knight_pos[1] + 2 || castle[1] < knight_pos[1] - 2 ) {
       move(castle[0], castle[1]);
       print("Knight Moves To Maugrim Castle\n");
     // And Is In The Castle  
     } else {
          greet(this.King);
          //inv.take("Wolfsbane");
          //inv.take("Blade");
          //inv.take("Axe");
          //inv.take("Ale");
      }
      
  }   
}  

/**
 * Move The Knight To The Tar Pit & Fight Rameses.
 */
public void fightRameses() {
  
  // If Not At Tar Pit
  if ( tar_pit[0] > knight_pos[0] + 2 || tar_pit[0] < knight_pos[0] - 2 || tar_pit[1] > knight_pos[1] + 2 || tar_pit[1] < knight_pos[1] - 2 ) {
    move(tar_pit[0], tar_pit[1]);
    print("Knight Moves To Tar Pit\n");
       // If In The Tar Pit  
    } else {
      // Retrieve Weapon
      String weapon = "";
      if ( inv.fenrir == 1 ) {
        weapon = "Fenrir";
      } else if ( inv.fire >= 1 ) {
        weapon = "Fire";
      } else if ( inv.poisonedSword >= 1 ) {
        weapon = "Poisoned Sword";
      } 
      // Fight Rameses
      fight(this.Rameses, weapon);
    }
  
}  

/**
 * Move Knight To Character Location & Exchange Item With Character
 */ 
public void ExchangeWithCharacter(String name, String give, String take ) {
  
  int x = 0;
  int y = 0;
  String loc = "";
  KeyCharacter exchanger = null;
  
  // Get Character Coordinates
  if ( name.equals("Lady Lupa") ) {
    x = cave[0];
    y = cave[1];
    loc = "Ancient Cave";
    exchanger = this.LadyLupa;
  } else if ( name.equals("Tree Spirit") ) {
    x = tree[0];
    y = tree[1];
    loc = "Supernatural Forest";
    exchanger = this.TreeSpirit;
  } else if ( name.equals("Blacksmith") ) {
    x = forge[0];
    y = forge[1];
    loc = "Forge";
    exchanger = this.Blacksmith;
  } else if ( name.equals("Innkeeper") ) {
    x = tavern[0];
    y = tavern[1];
    loc = "Tavern";
    exchanger = this.Innkeeper;
  } else {
    return;
  } 
  
  // If The Knight Is Not At Character Location
  if ( x > knight_pos[0] + 2 || x < knight_pos[0] - 2 ||  y > knight_pos[1] + 2 || y < knight_pos[1] - 2 ) {
    move(x, y);
    print("Knight Moves To " + loc + "\n");
  // If Knight Is At Character Location      
  } else {
    exchange(exchanger, give, take);
    print( "Knight gives " + exchanger.name + " " + give + " and takes " + take + "\n" );
  }
  
}  

/**
 * Knight Remains Static And Combines Two Items
 */
public void CombineItems( String Item1, String Item2 ) {
  use( Item1, Item2, "Item");
}  

/**
 * Knight Moves To Character Location And Uses Item On Character
 */
public void UseItemOnCharacter( String item, String name ) {
  
  int x = 0;
  int y = 0;
  String loc = "";
  
  // Get Character Coordinates
  if ( name.equals("Lady Lupa") ) {
    x = cave[0];
    y = cave[1];
    loc = "Ancient Cave";
  } else if ( name.equals("Tree Spirit") ) {
    x = tree[0];
    y = tree[1];
    loc = "Supernatural Forest";
  } else if ( name.equals("Blacksmith") ) {
    x = forge[0];
    y = forge[1];
    loc = "Forge";
  } else if ( name.equals("Innkeeper") ) {
    x = tavern[0];
    y = tavern[1];
    loc = "Tavern";
  } else {
    return;
  } 
  
  // If The Knight Is Not At Character Location
    // And Is Not At Location
    if ( x > knight_pos[0] + 2 || x < knight_pos[0] - 2 ||  y > knight_pos[1] + 2 || y < knight_pos[1] - 2 ) {
     move(x, y);
     print("Knight Moves To " + loc + "\n");
    // Or Is At Location 
    } else {
      use(item, name, "Person");
    }  
  

}  



/**
 * Move The Knight To The x & y Coordinates.
 */
public void move( int x, int y ) {
  if ( x != castle[0] || y!= castle[1] ) {
    delay(500);
  }
  target_pos[0] = x;
  target_pos[1] = y;
  pathFindAStar( knight_pos, target_pos );
  this.unfinished = true;
  this.index = 0; 
}  

/**
 * The Knight Can Greet A King And Recieve Gold.
 */
public void greet( KeyCharacter character ) {
  if ( character.equals(this.King) ) {
    inv.gold+= kings_gold;
    print("Knight Greets King\n");
  }  
}  

/**
 * The Knight Can Fight A Character That Is Rameses.
 */ 
public void fight( KeyCharacter character, String weapon ) {
  if ( character.equals(this.Rameses) ) {
    print("Knight Fights Rameses With " + weapon + "\n");
    if ( weapon.equals("Poisoned Sword") || weapon.equals("Fire") || weapon.equals("Fenrir") || weapon.equals("Poisoned Fenrir") ) {
      if ( weapon.equals("Fire") ) {
        print("Knight Burns Tar Pits\n");
      }  
      print("Knight Defeats Rameses \n");
      this.done = true;
    } else {
      print("Knight Is Killed By Rameses \n");
      this.done = true;
    }  
  }   
} 

/**
 * Use Two Items Together Or Use An Item On A Person Or Place.
 */
public void use( String Item1, String Item2, String Item2Class ) {
  
  // If Using Two Items Together
  if ( Item2Class.equals("Item") ) {
    
   if ( Item1.equals("Wood") ) {
     if ( Item2.equals("Ale") ) {
       inv.give("Wood");
       inv.give("Ale");
       inv.take("Fire");
       print("Knight Uses Wood & Ale To Create Fire\n");
     } else if ( Item2.equals("Blade") ) {
       inv.give("Wood");
       inv.give("Blade");
       inv.take("Sword");
       print("Knight Uses Wood & A Blade To Create A Sword\n");
     }
     
   } else if ( Item2.equals("Wood") ) {
     if ( Item1.equals("Ale") ) {
       inv.give("Wood");
       inv.give("Ale");
       inv.take("Fire");
       print("Knight Uses Wood & Ale To Create Fire\n");
     } else if ( Item1.equals("Blade") ) {
       inv.give("Wood");
       inv.give("Blade");
       inv.take("Sword");
       print("Knight Uses Wood & A Blade To Create A Sword\n");
     }
     
   } else if ( Item1.equals("Wolfsbane") ) {
     if ( Item2.equals("Sword")) {
       inv.give("Sword");
       inv.give("Wolfsbane");
       inv.take("Poisoned Sword");
       print("Knight Uses A Sword & Wolfsbane To Create A Poisoned Sword\n");
     } else if (Item2.equals("Fenrir")) {
       inv.give("Fenrir");
       inv.give("Wolfsbane");
       inv.take("Poisoned Fenrir");
       print("Knight Uses Fenrir & Wolfsbane To Create A Poisoned Fenrir\n");
     }  
     
   } else if ( Item2.equals("Wolfsbane") ) {
     if ( Item1.equals("Sword")) {
       inv.give("Sword");
       inv.give("Wolfsbane");
       inv.take("Poisoned Sword");
       print("Knight Uses A Sword & Wolfsbane To Create A Poisoned Sword\n");
    } else if (Item1.equals("Fenrir")) {
       inv.give("Fenrir");
       inv.give("Wolfsbane");
       inv.take("Poisoned Fenrir");
       print("Knight Uses Fenrir & Wolfsbane To Create A Poisoned Fenrir\n");
    }
    
   }  
  
  // If Using Item On A Person
  } else if ( Item2Class.equals("Person") ) {
    
    if ( Item2.equals("Rameses") ) {
      fight(this.Rameses, Item1);
    } 
    
    if ( Item2.equals("Tree Spirit") ) {
      if( Item1.equals("Axe") ) {
        inv.take("Wood");
        print("Knight Uses Axe On Tree Spirit To Obtain Wood\n");
      }  
    }  
    
  // If Using An Item On A Place
  } else if ( Item2Class.equals("Place") ) {
    // No Places Right Now
  }  
  
}  

/**
 * The Knight Can Exchange A Wanted Item With Another Character
 */
public void exchange( KeyCharacter exchanger, String give, String take ) {
  if ( exchanger.wants(give) && inv.contains(give) ) {
    inv.take(take);
    inv.give(give);
  }
}  

/**
 * Draws Obstacles From The Obstacle Array
 */
void draw_obstacles() {
  
    for ( int i = 0; i < this.obstacles.size(); i++ ) {
      fill(167); // Color The Obstacle
      //stroke(47);
      beginShape(); // Began The Obstacle
      for ( int j = 0; j < this.obstacles.get(i).size(); j+=2 ) {
        vertex(this.obstacles.get(i).get(j), this.obstacles.get(i).get(j + 1)); // Print Each Vertex
      }
      endShape(CLOSE); // Finish The Obstacle
    }  
  
}  

/**
 * Draws The Castle Key Location
 */
void draw_castle(int x, int y) {
  fill(255); // Castle Body
  noStroke();
  rect( x - 30, y - 15, 60, 30 );
  fill(0); // Castle Door
  stroke(255);
  rect( x - 10, y, 20, 15 );
  fill(255);
  noStroke();
  rect( x - 1, y, 2, 15 );
  fill(255); // Castle Ornaments 
  noStroke();
  rect( x - 8, y - 30, 16, 15 );
  rect( x - 30, y - 30, 16, 15 );
  rect( x + 14, y - 30, 16, 15 );
}

/** 
 * Draws The Tar Pit Key Location 
 */
void draw_tar_pit(int x, int y) {
  fill(255);
  noStroke();
  ellipse(x - 10, y - 7, 55, 18);
  ellipse(x + 10, y + 5, 55, 18);
}

/**
 * Draws The Tavern Key Location
 */
void draw_tavern(int x, int y) {
  fill(255);
  beginShape(); // Tavern Roof
  vertex( x - 24, y);
  vertex ( x - 12, y - 13 );
  vertex ( x + 12, y - 13 );
  vertex ( x + 24, y );
  endShape(CLOSE);
  rect(x - 15, y, 30, 15); // Tavern Body
  fill(0);
  stroke(255);
  rect( x - 5, y + 5, 10, 10 ); // Tavern Door
  fill(255); // Tavern Chimney Stack
  noStroke();
  rect( x + 4, y - 19, 8, 6 );
  ellipse( x + 2, y + 10, 2, 2 ); // Tavern Door Knob
}

/**
 * Draws The Tree Key Location
 */
void draw_tree(int x, int y) {
  fill(255);
  rect( x - 5, y, 10, 28 ); // Trunk
  ellipse( x, y - 5, 38, 40 ); // Leaves
  ellipse( x - 16, y + 3, 20, 22 );
  ellipse( x + 16, y + 3, 20, 22 );
}

/**
 * Draws The Cave Key Location
 */
void draw_cave(int x, int y) {
  fill(255);
  noStroke();
  beginShape(); // Cave Body
  vertex( x - 20, y + 15 );
  vertex( x, y - 20 );
  vertex( x + 20, y + 15 );
  endShape(CLOSE);
  beginShape(); // Cave Small Peak 1
  vertex(x - 27, y + 15);
  vertex(x - 17, y);
  vertex(x - 7, y + 15);
  endShape(CLOSE);
  beginShape(); // Cave Small Peak 2
  vertex(x + 27, y + 15);
  vertex(x + 17, y);
  vertex(x + 7, y + 15);
  endShape(CLOSE);
  fill(0);
  beginShape(); // Cave Enterance
  vertex(x - 7, y + 15);
  vertex(x, y + 2);
  vertex(x + 7, y + 15);
  endShape(CLOSE);
}

/**
 * Draws The Forge Key Location
 */
void draw_forge(int x, int y) {
  fill(255);
  noStroke();
  rect( x - 15, y - 6, 30, 12 );
  rect( x - 15, y + 10, 30, 2 );
  beginShape(); // fire
  vertex( x - 9, y - 6 );
  vertex( x, y - 25 );
  vertex( x + 9, y - 6 );
  endShape(CLOSE);
  beginShape(); // fire
  vertex( x - 13, y - 6 );
  vertex( x - 10, y - 17 );
  vertex( x - 7, y - 6 );
  endShape(CLOSE);
  beginShape(); // fire
  vertex( x + 13, y - 6 );
  vertex( x + 10, y - 17 );
  vertex( x + 7, y - 6 );
  endShape(CLOSE);
}  

/**
 * Draws The Knight Represented As A Horse
 */
void draw_knight(int x, int y) {
  fill(255); // Head Horse Hair
  ellipse(x - 1, y - 15, 20, 20); 
  fill(200,0,0);
  noStroke();
  ellipse(x, y - 10, 20, 20); // Horse Head
  ellipse(x + 15, y + 6, 12, 12); // Horse Nose
  beginShape(); // Horse Snout
  vertex(x + 6, y - 16);
  vertex(x + 17, y);
  vertex(x + 17, y + 11);
  vertex(x - 2, y + 2);
  endShape(CLOSE);
  noStroke();
  fill(255); // Neck Horse Hair
  ellipse(x - 10, y - 15, 5, 5);
  ellipse(x - 12, y - 10, 5, 5);
  ellipse(x - 14, y - 5, 5, 5);
  ellipse(x - 16, y, 5, 5);
  ellipse(x - 18, y + 5, 5, 5);
  fill(200,0,0); 
  noStroke();
  beginShape(); // Horse Neck
  vertex(x - 11, y - 10);
  vertex(x - 20, y + 8);
  vertex(x, y + 8);
  vertex(x + 3, y + 2);
  endShape(CLOSE);
  beginShape(); // Horse Ear
  vertex(x - 13, y - 5);
  vertex(x - 3, y - 32);
  vertex(x + 9, y - 5);
  endShape(CLOSE);
  fill(255); // Horse Eye
  stroke(0);
  ellipse(x + 3, y - 10, 5, 5);
  fill(0); // Horse Nostril
  noStroke();
  ellipse(x + 17, y + 5, 2, 2);
  beginShape();  // Mouth
  vertex(x + 17, y + 10);
  vertex(x + 13, y + 8);
  vertex(x + 13, y + 9);
  vertex(x + 17, y + 11);
  endShape(CLOSE);
  beginShape();  // Horse Inner Ear
  vertex(x - 6, y - 19);
  vertex(x - 3, y - 27);
  vertex(x - 1, y - 19);
  endShape(CLOSE);
}

/**
 * A character with wants and services.
 */
public class KeyCharacter {
  
  String name;
  ArrayList<String> wants;
  ArrayList<String> services;
  
  public KeyCharacter( String name ) {
    this.wants = new ArrayList<String>();
    this.services = new ArrayList<String>();
    this.name = name;
  } 
  
  public ArrayList<String> getWants() {
    return wants;
  }  
  
  public ArrayList<String> getServicies() {
    return services;
  }
  
  public boolean hasService( String service ) {
    boolean ret = false;
    for ( int i = 0; i < services.size(); i++ ) {
      if ( services.get(i).equals(service)) {
        ret = true;
      }  
    }  
    return ret;
  }  
  
  public boolean wants( String want ) {
    boolean ret = false;
    for ( int i = 0; i < wants.size(); i++ ) {
      if ( wants.get(i).equals(want)) {
        ret = true;
      }  
    }  
    return ret;
  }  
  
}  

/**
 * An inventory of ownable items.
 */
public class Inventory {
  
  int gold;
  int axe;
  int wood;
  int blade;
  int sword;
  int poisonedSword;
  int wolfsbane;
  int fenrir;
  int poisonedFenrir;
  int water;
  int ale;
  int fire;
  
  public Inventory () {
    
    this.gold = 0;
    this.axe = 0;
    this.wood = 0;
    this.blade = 0;
    this.sword = 0;
    this.poisonedSword = 0;
    this.wolfsbane = 0;
    this.fenrir = 0;
    this.poisonedFenrir = 0;
    this.water = 0;
    this.ale = 0;
    this.fire = 0;
    
  }  
  
  public boolean contains( String item ) {
    if ( item.equals("1gold") && this.gold > 0 ) {
      return true;
    } 
    if ( item.equals("Axe") && this.axe > 0 ) {
      return true;
    } 
    if ( item.equals("Wood") && this.wood > 0 ) {
      return true;
    } 
    if ( item.equals("Blade") && this.blade > 0 ) {
      return true;
    } 
    if ( item.equals("Sword") && this.sword > 0 ) {
      return true;
    } 
    if ( item.equals("Poisoned Sword") && this.poisonedSword > 0 ) {
      return true;
    } 
    if ( item.equals("Wolfsbane") && this.wolfsbane > 0 ) {
      return true;
    } 
    if ( item.equals("Fenrir") && this.fenrir > 0 ) {
      return true;
    } 
    if ( item.equals("Poisoned Fenrir") && this.poisonedFenrir > 0 ) {
      return true;
    } 
    if ( item.equals("Water") && this.water > 0 ) {
      return true;
    } 
    if ( item.equals("Ale") && this.ale > 0 ) {
      return true;
    } 
    if ( item.equals("Fire") && this.fire > 0 ) {
      return true;
    } 
    return false;
  }  
  
  public void take( String item ) {
    if ( item.equals("1gold") ) {
      this.gold++;
    } 
    if ( item.equals("Axe") ) {
      this.axe++;
    } 
    if ( item.equals("Wood") ) {
      this.wood++;
    } 
    if ( item.equals("Blade") ) {
      this.blade++;
    } 
    if ( item.equals("Sword") ) {
      this.sword++;
    } 
    if ( item.equals("Poisoned Sword") ) {
      this.poisonedSword++;
    } 
    if ( item.equals("Wolfsbane") ) {
      this.wolfsbane++;
    } 
    if ( item.equals("Fenrir") ) {
      this.fenrir++;
    } 
    if ( item.equals("Poisoned Fenrir") ) {
      this.poisonedFenrir++;
    } 
    if ( item.equals("Water") ) {
      this.water++;
    } 
    if ( item.equals("Ale") ) {
      this.ale++;
    } 
    if ( item.equals("Fire") ) {
      this.fire++;
    }   
  }
  
  public void give( String item ) {
    if ( item.equals("1gold") && this.gold > 0 ) {
      this.gold--;
    } 
    if ( item.equals("Axe") && this.axe > 0 ) {
      this.axe--;
    } 
    if ( item.equals("Wood") && this.wood > 0 ) {
      this.wood--;
    } 
    if ( item.equals("Blade") && this.blade > 0 ) {
      this.blade--;
    } 
    if ( item.equals("Sword") && this.sword > 0 ) {
      this.sword--;
    } 
    if ( item.equals("Poisoned Sword") && this.poisonedSword > 0 ) {
      this.poisonedSword--;
    } 
    if ( item.equals("Wolfsbane") && this.wolfsbane > 0 ) {
      this.wolfsbane--;
    } 
    if ( item.equals("Fenrir") && this.fenrir > 0 ) {
      this.fenrir--;
    } 
    if ( item.equals("Poisoned Fenrir") && this.poisonedFenrir > 0 ) {
      this.poisonedFenrir--;
    } 
    if ( item.equals("Water") && this.water > 0 ) {
      this.water--;
    } 
    if ( item.equals("Ale") && this.ale > 0 ) {
      this.ale--;
    } 
    if ( item.equals("Fire") && this.fire > 0 ) {
      this.fire--;
    }   
  }
  
}  

/**
 * Given a particular node, returns an arraylist of its connections.
 */
public ArrayList< Connection > getConnections( int[] fromNode ) {
  ArrayList< Connection > connections = new ArrayList< Connection >();
  Connection west = new Connection( fromNode, 1 );
  Connection north = new Connection( fromNode, 2 );
  Connection east = new Connection ( fromNode, 3 );
  Connection south = new Connection ( fromNode, 4 );
  if ( west.isValid() ) {
    connections.add( west );
  }
  if ( north.isValid() ) {
    connections.add( north );
  }  
  if ( east.isValid() ) {
    connections.add( east );
  }  
  if ( south.isValid() ) {
    connections.add( south );
  }  
  return connections;
}  

/**
 * A class for connection for a node in a graph. 
 */
public class Connection {
  
  NodeRecord fromNode;
  NodeRecord toNode;
  int cost;
  boolean valid;
  
  /**
   * Recieves the from node, a size two array with an x and y
   * value and a direction ( 1 = west, 2 = north, 3 = east, 4 = south )
   * and sets the local variables fromNode, toNode, cost ( always 1 ), 
   * and validility ( whether it crosses an obstacle ).
   */
  public Connection( int[] fromNode, int direction ) {
    
    
    // Set fromNode
    this.fromNode = new NodeRecord( fromNode[0], fromNode[1] );
    
    // Set toNode
    this.toNode = new NodeRecord( fromNode[0], fromNode[1] );
    
    // If direction = 1, west,
    // toNode = ( x--, y )
    if ( direction == 1 ) {
      this.toNode.node[0] = this.toNode.node[0] - 2;
    }
    
    // If direction = 2, north,
    // toNode = ( x, y++ )
    if ( direction == 2 ) {
      this.toNode.node[1] = this.toNode.node[1] + 2;
    }  
    
    // If direction = 3, east, 
    // toNode = ( x++, y )
    if ( direction == 3 ) {
      this.toNode.node[0] = this.toNode.node[0] + 2;
    }  
    
    // If direction = 4, south, 
    // toNode = ( x, y-- )
    if ( direction == 4 ) {
      this.toNode.node[1] = this.toNode.node[1] -2;
    }      
    
    // Set Validility ... First Check Boundaries
    
    // If x is 0 or 640 ... validility is false,
    if ( toNode.node[0] <= 0 || toNode.node[0] >= 640 ) {
      this.valid = false;
    // Else if y is 0 or 480   ... validility is false, 
    }  else if ( toNode.node[1] <= 0 || toNode.node[1] >= 480 ) {
      this.valid = false;
    // Else ... validility is true. 
    } else {
      this.valid = true;
    } 
    
    // Set cost as 1
    this.cost = 1;
    
    // Next Check Obstacles ...
    for ( int i = 0; i < obstacles.size(); i++ ) {
      
      // check first with last ..
      int x1 = obstacles.get(i).get( obstacles.get(i).size() - 2 );
      int y1 = obstacles.get(i).get( obstacles.get(i).size() - 1 );
      int x2 = obstacles.get(i).get(0);
      int y2 =  obstacles.get(i).get(1);
      int x_max = x1;
      int x_min = x2;

      if ( x2 > x1 ) {
        x_max = x2;
        x_min = x1;
      }  
      int y_max = y1;
      int y_min = y2;
      if ( y2 > y1 ) {
        y_max = y2;
        y_min = y1;
      }  
      
      // In the special case that you are moving horizontally
      if ( x2 == x1 ) {
        // If toNode is x and also within y range, it is invalid. 
        if ( toNode.node[0] == x_max  && toNode.node[1] <= y_max && toNode.node[1] >= y_min ) {
          this.valid = false;
        }  
        // If toNode is x and also within y range, it is invalid. 
        if ( toNode.node[0] == x_max + 1  && toNode.node[1] <= y_max && toNode.node[1] >= y_min ) {
          this.valid = false;
        }  
        // If toNode is x and also within y range, it is invalid. 
        if ( toNode.node[0] == x_max - 1  && toNode.node[1] <= y_max && toNode.node[1] >= y_min ) {
          this.valid = false;
        }  
      } else if ( toNode.node[0] <= x_max && toNode.node[0] >= x_min && toNode.node[1] <= y_max && toNode.node[1] >= y_min) {
         // Determine the slope
         float yChange = y2 - y1;
         float xChange = x2 - x1;
         float m = yChange / xChange;
         float invalidY1 = ( m * toNode.node[0] ) - ( m * x1 ) + y1;
         float invalidY2 = ( m * this.fromNode.node[0] ) - ( m * x1 ) + y1;
         float invalidY_Max = invalidY1;
         float invalidY_Min = invalidY2;
         if ( invalidY_Min > invalidY_Max ) {
             invalidY_Max = invalidY2;
             invalidY_Min = invalidY1;
         }    
         // If our y is the floor or ceiling of that y, it is invalid
         if ( toNode.node[1] <= ceil(invalidY_Max) + 2 && toNode.node[1] >= floor(invalidY_Min) - 2 ) {
           this.valid = false;
         }  
      } 
      
      // check others ...
      for ( int j = 0; j < obstacles.get(i).size() - 2; j+=2 ) {
        x1 = obstacles.get(i).get(j);
        y1 = obstacles.get(i).get(j + 1);
        x2 = obstacles.get(i).get(j + 2);
        y2 =  obstacles.get(i).get(j + 3);
        x_max = x1;
        x_min = x2;
        if ( x2 > x1 ) {
          x_max = x2;
          x_min = x1;
        }  
        y_max = y1;
        y_min = y2;
        if ( y2 > y1 ) {
          y_max = y2;
          y_min = y1;
        }  
        // In the special case that you are moving horizontally
        if ( x2 == x1 ) {
          
          // If toNode is x and also within y range, it is invalid. 
          if ( toNode.node[0] == x_max  && toNode.node[1] <= y_max && toNode.node[1] >= y_min ) {
            this.valid = false;
          }  
         // If toNode is x and also within y range, it is invalid. 
         if ( toNode.node[0] == x_max + 1  && toNode.node[1] <= y_max && toNode.node[1] >= y_min ) {
          this.valid = false;
         }  
         // If toNode is x and also within y range, it is invalid. 
        if ( toNode.node[0] == x_max - 1  && toNode.node[1] <= y_max && toNode.node[1] >= y_min ) {
          this.valid = false;
        }  
        
        } else if ( toNode.node[0] <= x_max && toNode.node[0] >= x_min && toNode.node[1] <= y_max && toNode.node[1] >= y_min) {
           
           // Determine the slope
           float yChange = y2 - y1;
           float xChange = x2 - x1;
           float m = yChange / xChange;
           // Plug in toNode x to find the invalid y.
           float invalidY1 = ( m * toNode.node[0] ) - ( m * x1 ) + y1;
           float invalidY2 = ( m * this.fromNode.node[0] ) - ( m * x1 ) + y1;
           float invalidY_Max = invalidY1;
           float invalidY_Min = invalidY2;
           if ( invalidY_Min > invalidY_Max ) {
             invalidY_Max = invalidY2;
             invalidY_Min = invalidY1;
           }  
           // If our y is the floor or ceiling of that y, it is invalid
           if ( toNode.node[1] <= ceil(invalidY_Max) + 2 && toNode.node[1] >= floor(invalidY_Min) - 2 ) {
             this.valid = false;
           }
           
        }  
      }
    }
    
    
  }  
  
  /**
   * Returns the fromNode.
   */
  public NodeRecord getFromNode() {
    return fromNode;
  }  
  
  /**
   * Returns the toNode. 
   */
  public NodeRecord getToNode() {
    return toNode;
  }  
  
  /**
   * Returns whether the connection is valid. 
   */
  public boolean isValid() {
    return valid;
  }
  
  /**
   * Returns the cost of the connection. 
   */
  public int getCost() {
    return cost;
  }  
  
}

/**
 * An object for keeping track of node information.
 */
public class NodeRecord {
  int[] node;
  Connection connection;
  int costSoFar;
  float estimatedTotalCost;
  
  /**
   * Creates a new node record with no node in mind.
   */
  NodeRecord() {
    this.node = new int[2];
    this.node[0] = 0;
    this.node[0] = 0;
    this.connection = null;
    this.costSoFar = 0;
    this.estimatedTotalCost = 0;
  } 
  
  /**
   * Creates a new node record with a specific node in mind. 
   */
  NodeRecord( int x, int y ) {
    this.node = new int[2];
    this.node[0] = x;
    this.node[1] = y;
    this.connection = null;
    this.costSoFar = 0;
    this.estimatedTotalCost = 0;
  }  
}  

class NodeRecordSorter implements Comparator<NodeRecord> {
  public int compare(NodeRecord a, NodeRecord b) {
    return round(a.estimatedTotalCost) - round(b.estimatedTotalCost);
  }  
}  

/**
 * Hueristic that finds distance between two points. 
 * The points x1 and y1 should correspond to the current
 * node and x2 and y2 shoud correspond to the target node. 
 * Returns the distance, a float, between two points. 
 */
public float hueristic( int x1, int y1, int x2, int y2 ) {
  float xSquare = sq( x2 - x1 );
  float ySquare = sq( y2 - y1 );
  float ret = sqrt( xSquare + ySquare );
  return ret;
}  


/**
 * Path for setting or resetting a path to follow.
 */
public void pathFindAStar( int[] start, int[] end ) {
   
  // Initializes the record for the start node. 
  NodeRecord startRecord = new NodeRecord( start[0], start[1] );
  startRecord.estimatedTotalCost = hueristic( start[0], start[1], end[0], end[1] );
  
  // Initialize the open list of nodes that need to be seen. 
  // ArrayList< NodeRecord > open = new ArrayList< NodeRecord >();
  NodeRecordSorter sorter = new NodeRecordSorter();
  PriorityQueue<NodeRecord> open = new PriorityQueue<NodeRecord>( 100, sorter );
  open.add(startRecord);
  
  // Initialize the closed list of nodes that have already been seen. 
  ArrayList< NodeRecord > closed = new ArrayList< NodeRecord >();

  NodeRecord currentRecord = new NodeRecord();
  
  // Iterate through processing each node.
  while ( open.size() != 0 ) {
    
    // Choose the node from the open list with the lowest estimated total cost so far.
    currentRecord = open.peek();
  
    // If the current record contains the end node, break from while loop.
    if ( currentRecord.node[0] == end[0] && currentRecord.node[1] == end[1] ) {
      break;
    }
    if ( currentRecord.node[0] >= end[0] - 2 && currentRecord.node[0] <= end[0] + 2 ) {
      if ( currentRecord.node[1] >= end[1] - 2 && currentRecord.node[1] <= end[1] + 2 ) {
        break;
      }  
    }  
    
    // Else, get the current nodes outward connections.
    ArrayList< Connection > connections = getConnections( currentRecord.node );
    // Loop through each connection in turn.
    for ( int i = 0; i < connections.size(); i++ ) {
      
      // Retrieve the end node.
      int[] endNode = connections.get(i).getToNode().node;
      
      // Calculate the estimated code of that end node. 
      int endNodeCost = currentRecord.costSoFar + connections.get(i).getCost();
      
      // Check if our "endNode" is closed.
      boolean isClosed = false;
      // The matching record in the closed array.
      NodeRecord matchingRecClosed = new NodeRecord();
      for ( int j = 0; j < closed.size(); j++ ) {
        if ( closed.get(j).node[0] == endNode[0] && closed.get(j).node[1] == endNode[1] ) {
          isClosed = true;
          matchingRecClosed = closed.get(j);
        }  
      }  
      
      // Check if our "endNode" is already open and if so set matchingRec.
      boolean isOpen = false;
      // The matching record in the open array.
      NodeRecord matchingRecOpen = new NodeRecord();
      NodeRecord[] arr1 = new NodeRecord[open.size()];
      NodeRecord[] arr2 = open.toArray(arr1);
      for ( int k = 0; k < open.size(); k++ ) {
        if ( arr2[k].node[0] == endNode[0] && arr2[k].node[1] == endNode[1] ) {
          isOpen = true;
          matchingRecOpen = arr2[k];
        }  
      }
      
      // If the node is closed we may have to skip or remove it from the closed list.
      if ( isClosed ) {
        
        // If we didn't find a shorter route, skip.
        if ( matchingRecClosed.costSoFar <= endNodeCost ) {
          continue;
        } else {
        
          // Otherwise remove it from the closed list. 
          for ( int k = 0; k < closed.size(); k++ ) {
            // Has Matching Nodes
            if ( closed.get(k).node[0] == currentRecord.node[0] && closed.get(k).node[1] == currentRecord.node[1] ) {
              // And Matching Costs
              if ( closed.get(k).costSoFar == currentRecord.costSoFar ) {
            
                // Matching Null Connections 
                if ( closed.get(k).connection == null ) {
                  if ( currentRecord.connection == null ) {
                    closed.remove(k);
                  }  
                // Or Matching Connection From Nodes ( Variable x )
                } else if ( currentRecord.connection != null && closed.get(k).connection.getFromNode().node[0] == currentRecord.connection.getFromNode().node[0] ) {
                  // And Matching Connection From Nodes ( Variable y )
                  if ( closed.get(k).connection.getFromNode().node[0] == currentRecord.connection.getFromNode().node[0] ) {
                    closed.remove(k);
                  }  
                }  
            
              }   // closing "And Matching Costs"
            }  // closing "Has Matching Nodes"
          } // closing for loop for closed list
     
          // Set end node hueristic.
          float endNodeHueristic = hueristic( endNode[0], endNode[1], end[0], end[1] );
          //float endNodeHueristic = matchingRecClosed.estimatedTotalCost - matchingRecClosed.costSoFar;
        
          // Add an updated "matchingRecClosed" to open list.
          matchingRecClosed.costSoFar  = endNodeCost;
          matchingRecClosed.connection = connections.get(i);
          // Ensure that every record added has appropriate links
          matchingRecClosed.connection.fromNode = currentRecord;
          matchingRecClosed.connection.toNode = matchingRecClosed;
          matchingRecClosed.estimatedTotalCost = endNodeCost + endNodeHueristic;
          open.add(matchingRecClosed);
          
        }  
        
      // Else if the node is open, skip if we have a better route. 
      }  else if ( isOpen ) {
        
        // if our route is no better, skip.
        if ( matchingRecOpen.costSoFar <= endNodeCost ) {
          continue;
        } else {
          
           // Set end node hueristic.
          float endNodeHueristic = hueristic( endNode[0], endNode[1], end[0], end[1] );
          
          // Add an updated "matchingRecClosed" to open list.
          matchingRecOpen.costSoFar  = endNodeCost;
          matchingRecOpen.connection = connections.get(i);
          // Ensure that every record added has appropriate links
          matchingRecOpen.connection.fromNode = currentRecord;
          matchingRecOpen.connection.toNode = matchingRecOpen;
          matchingRecOpen.estimatedTotalCost = endNodeCost + endNodeHueristic;
          open.add(matchingRecOpen);
          
        }  
            
      // Oterwise, we have an unvisited node, so make a record of it.
      } else {
        
        NodeRecord newRec = new NodeRecord();
        newRec.node = endNode;
        
        // Set end node hueristic.
        float endNodeHueristic = hueristic( endNode[0], endNode[1], end[0], end[1] );
        //float endNodeHueristic = matchingRecOpen.estimatedTotalCost - matchingRecOpen.costSoFar;
        
        // We're here if we need to update the update the node, update
        // the cost and update the connection.
        newRec.costSoFar = endNodeCost;
        newRec.connection = connections.get(i);
        // ensure that every record added has appropriate links
        newRec.connection.fromNode = currentRecord;
        newRec.connection.toNode = newRec;
        newRec.estimatedTotalCost = endNodeCost + endNodeHueristic;
        open.add( newRec );
        
      }  
      
    } // end connections for loop
   
    open.remove(currentRecord);
    closed.add(currentRecord);
  } // end while loop
  
  // If we ran out of nodes without a solution, set unfinished to false.
  // Otherwise set the path.  
  boolean valid_path = false;
  if ( currentRecord.node[0] >= end[0] - 2 && currentRecord.node[0] <= end[0] + 2 ) {
      if ( currentRecord.node[1] >= end[1] - 2 && currentRecord.node[1] <= end[1] + 2 ) {
        valid_path = true;
      } 
  } 
  if ( valid_path == false ) {
    this.unfinished = false;
  }  else {
    // Reset the path.
    this.path = new ArrayList< int[] >();
    // Work back along the path, accumalationg connections. 
    
    while ( currentRecord.node[0] != start[0] || currentRecord.node[1] != start[1] ) {
     
      // Add current node to the beganning of the path.
      int[] newNode = new int[2];
      newNode[0] = currentRecord.node[0];
      newNode[1] = currentRecord.node[1];
      this.path.add( 0, newNode );
      
      currentRecord = currentRecord.connection.getFromNode();    
    }  

  }
} // end Dijkstra's Algorithm
