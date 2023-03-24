//
// Utils.qc
//
// This file contains a bunch of useful definitions and utilities.
//

// Overloaded centerprints
void (entity client, string s1, string s2) centerprint2 = #73;
void (entity client, string s1, string s2, string s3) centerprint3 = #73;
void (entity client, string s1, string s2, string s3, string s4) centerprint4 = #73;
void (entity client, string s1, string s2, string s3, string s4, string s5) centerprint5 = #73;
void (entity client, string s1, string s2, string s3, string s4, string s5, string s6) centerprint6 = #73;
void (entity client, string s1, string s2, string s3, string s4, string s5, string s6, string s7) centerprint7 = #73;

// Overloaded sprints
void (entity client, float level, string s1, string s2) qw_sprint2 = #24;
void (entity client, float level, string s1, string s2, string s3) qw_sprint3 = #24;
void (entity client, float level, string s1, string s2, string s3, string s4) qw_sprint4 = #24;
void (entity client, float level, string s1, string s2, string s3, string s4, string s5) qw_sprint5 = #24;
void (entity client, float level, string s1, string s2, string s3, string s4, string s5, string s6) qw_sprint6 = #24;
void(entity e, string s1, string s2) sprint2 = { qw_sprint2(e, PRINT_MEDIUM, s1, s2); };
void(entity e, string s1, string s2, string s3) sprint3 = { qw_sprint3(e, PRINT_MEDIUM, s1, s2, s3); };
void(entity e, string s1, string s2, string s3, string s4) sprint4 = { qw_sprint4(e, PRINT_MEDIUM, s1, s2, s3, s4); };
void(entity e, string s1, string s2, string s3, string s4, string s5) sprint5 = { qw_sprint5(e, PRINT_MEDIUM, s1, s2, s3, s4, s5); };
void(entity e, string s1, string s2, string s3, string s4, string s5, string s6) sprint6 = { qw_sprint6(e, PRINT_MEDIUM, s1, s2, s3, s4, s5, s6); };

// Overloaded bprints
void (float level, string s1, string s2) qw_bprint2 = #23;
void (float level, string s1, string s2, string s3) qw_bprint3 = #23;
void (float level, string s1, string s2, string s3, string s4) qw_bprint4 = #23;
void (float level, string s1, string s2, string s3, string s4, string s5) qw_bprint5 = #23;
void (float level, string s1, string s2, string s3, string s4, string s5, string s6) qw_bprint6 = #23;
void(string s1, string s2) bprint2 = { qw_bprint2(PRINT_MEDIUM, s1, s2); };
void(string s1, string s2, string s3) bprint3 = { qw_bprint3(PRINT_MEDIUM, s1, s2, s3); };
void(string s1, string s2, string s3, string s4) bprint4 = { qw_bprint4(PRINT_MEDIUM, s1, s2, s3, s4); };
void(string s1, string s2, string s3, string s4, string s5) bprint5 = { qw_bprint5(PRINT_MEDIUM, s1, s2, s3, s4, s5); };
void(string s1, string s2, string s3, string s4, string s5, string s6) bprint6 = { qw_bprint6(PRINT_MEDIUM, s1, s2, s3 ,s4, s5, s6); };

//
// Functions for printing to console
//
// Caution:  when printing multiple strings to the same line, use cprint
//           for the first string(s) and localcmd for subsequent strings.
//
// example:
//
// cprint3("my ", "name ", "is ");
// localcmd2("bob", "\n");
//
void (string s1, string s2) localcmd2 =
{
    localcmd(s1);
    localcmd(s2);
};

void (string s1, string s2, string s3) localcmd3 =
{
    localcmd(s1);
    localcmd(s2);
    localcmd(s3);
};

void (string s1, string s2, string s3, string s4) localcmd4 =
{
    localcmd(s1);
    localcmd(s2);
    localcmd(s3);
    localcmd(s4);
};

void (string s1, string s2, string s3, string s4, string s5) localcmd5 =
{
    localcmd(s1);
    localcmd(s2);
    localcmd(s3);
    localcmd(s4);
    localcmd(s5);
};

void (string s1, string s2, string s3, string s4, string s5, string s6) localcmd6 =
{
    localcmd(s1);
    localcmd(s2);
    localcmd(s3);
    localcmd(s4);
    localcmd(s5);
    localcmd(s6);
};

void (string s1, string s2, string s3, string s4, string s5, string s6, string s7) localcmd7 =
{
    localcmd(s1);
    localcmd(s2);
    localcmd(s3);
    localcmd(s4);
    localcmd(s5);
    localcmd(s6);
    localcmd(s7);
};

void (string s1) cprint =
{
    localcmd("echo ");
    localcmd(s1);  
};

void (string s1, string s2) cprint2 =
{
    localcmd("echo ");
    localcmd(s1);
    localcmd(s2);
};

void (string s1, string s2, string s3) cprint3 =
{
    localcmd("echo ");
    localcmd(s1);
    localcmd(s2);
    localcmd(s3);
};

void (string s1, string s2, string s3, string s4) cprint4 =
{
    localcmd("echo ");
    localcmd(s1);
    localcmd(s2);
    localcmd(s3);
    localcmd(s4);
};

void (string s1, string s2, string s3, string s4, string s5) cprint5 =
{
    localcmd("echo ");
    localcmd(s1);
    localcmd(s2);
    localcmd(s3);
    localcmd(s4);
    localcmd(s5);
};

void (string s1, string s2, string s3, string s4, string s5, string s6) cprint6 =
{
    localcmd("echo ");
    localcmd(s1);
    localcmd(s2);
    localcmd(s3);
    localcmd(s4);
    localcmd(s5);
    localcmd(s6);
};

//
//  B P R I N T  F L O A T
//
//  Broadcasts a float followed by a CR.
//
void (float f) utils_bprint_float =
{
    local string s;

    s = ftos(f);
    bprint2(s, "\n");
};

//
//  P R I N T  F L O A T
//
//  Prints a float followed by CR to 'self'.
//
void (float f) utils_print_float =
{
    local string s;

    s = ftos(f);
    sprint2(self, s, "\n");
};

//
//  P R I N T  I N T 3
//
//  Prints a 3 character integer to 'self'.
//
void (float f) utils_print_int3 =
{
    local float n;
    local string s;

    n = rint(f);
    if (n < 0)
    {
        if (n < -99)
            sprint(self, "-99");
        else if (n > -10)
            sprint(self, " ");
    }
    else
    {
        if (n < 100)
            sprint(self, " ");
        if (n < 10)
            sprint(self, " ");
    }
    s = ftos(n);
    sprint(self, s);
};

//
//  C P R I N T  I N T 3
//
//  Prints a 3 character integer to the console.
//
void (float f) utils_cprint_int3 =
{
    local float n;
    local string s;

    n = rint(f);
    if (n < 0)
    {
        if (n < -99)
            localcmd("-99");
        else if (n > -10)
            localcmd(" ");
    }
    else
    {
        if (n < 100)
            localcmd(" ");
        if (n < 10)
            localcmd(" ");
    }
    s = ftos(n);
    localcmd(s);
};

//
//  P R I N T  V E C
//
//  Prints a vector followed by CR to 'self'.
//  Used for debugging.
//
void (vector v) utils_print_vec =
{
    local string s;

    s = vtos(v);
    sprint2(self, s, "\n");
};

//
//  P R I N T  B I T
//
//  Prints a single bit to 'self'.
//  Used for debugging.
//
void (float b) utils_print_bit =
{
    if (b)
        sprint(self, "1");
    else
        sprint(self, "0");
};

//
//  P R I N T  B I N
//
//  Prints a binary number followed by CR to 'self'.
//  Used for debugging.
//
void (float n) utils_print_bin =
{
    local float bit;

    if (!n)
    {
        sprint(self, "0\n");
        return;
    }

    bit = 32768 * 32768 * 2;
    while (bit > 0.5)
    {
        if (n & bit)
        {
            while (bit > 0.5)
            {
                utils_print_bit(n & bit);
                bit = bit / 2;
            }
        }
        bit = bit / 2;
    }
    sprint(self, "\n");
};

//
//  D U M P  P O S I T I O N
//
//  Dumps all 3d position information for an entity to 'self'.
//  Used for debugging.
//
void (entity e) utils_dump_position =
{
    sprint(self, "origin = ");
    utils_print_vec(e.origin);
    sprint(self, "mins = ");
    utils_print_vec(e.mins);
    sprint(self, "maxs = ");
    utils_print_vec(e.maxs);
    sprint(self, "size = ");
    utils_print_vec(e.size);
    sprint(self, "absmin = ");
    utils_print_vec(e.absmin);
    sprint(self, "absmax = ");
    utils_print_vec(e.absmax);
};

//
//  M I N
//
float (float a, float b) utils_min =
{
    if (a < b)
        return a;
    return b;
};

//
//  M A X
//
float (float a, float b) utils_max =
{
    if (a > b)
        return a;
    return b;
};

//
//  M I N 3
//
float (float a, float b, float c) utils_min3 =
{
    local float d;
    if (a < b)
        d = a;
    else
        d = b;
    if (d < c)
        return d;
    return c;
};

//
//  M A X 3
//
float (float a, float b, float c) utils_max3 =
{
    local float d;
    if (a > b)
        d = a;
    else
        d = b;
    if (d > c)
        return d;
    return c;
};

//
//  M A K E  S C H E D U L E D  E V E N T
//
//  Creates a new dynamic entity which will call the given
//  think function after the given amout of time; the entity's
//  owner is 'self'.
//
entity (void() think_function, float think_time) utils_make_scheduled_event =
{
    local entity temp;
    temp = spawn();
    temp.classname = "elohim_temp";
    temp.owner = self;
    temp.nextthink = time + think_time;
    temp.think = think_function;
    return temp;
};

//
//  S E T  C V A R
//
//  Set the console variable 'cvar' to 'value'.
//
void (string cvar, float value) utils_set_cvar =
{
    local string temp;

    temp = ftos(value);
    cvar_set(cvar, temp);
};

//
//  D O  I T E M
//
//  Do something to all items of the given type.  For each item,
//  'dofunc()' is called with 'self' pointing to the item.
//
void (void () dofunc, string item_name) utils_do_item =
{
    local entity oldself;

    oldself = self;
    self = find(world, classname, item_name);
    while (self)
    {
        dofunc();
        self = find(self, classname, item_name);
    }
    self = oldself;
};

//
//  D O  I T E M S
//
//  Do the same thing to all respawnable items.
//
void (void () dofunc) utils_do_items =
{
    utils_do_item(dofunc, "item_health");
    utils_do_item(dofunc, "item_armor1");
    utils_do_item(dofunc, "item_armor2");
    utils_do_item(dofunc, "item_armorInv");
    utils_do_item(dofunc, "item_shells");
    utils_do_item(dofunc, "item_spikes");
    utils_do_item(dofunc, "item_rockets");
    utils_do_item(dofunc, "item_cells");
    utils_do_item(dofunc, "item_weapon_nailgun");
    utils_do_item(dofunc, "item_weapon_supernailgun");
    utils_do_item(dofunc, "item_weapon_supershotgun");
    utils_do_item(dofunc, "item_weapon_rocketlauncher");
    utils_do_item(dofunc, "item_weapon_grenadelauncher");
    utils_do_item(dofunc, "item_weapon_lightning");
    utils_do_item(dofunc, "item_sigil");
    utils_do_item(dofunc, "item_artifact_invulnerability");
    utils_do_item(dofunc, "item_artifact_envirosuit");
    utils_do_item(dofunc, "item_artifact_invisibility");
    utils_do_item(dofunc, "item_artifact_super_damage");
};

float ELOHIM_CONNECTED = 8192;       // client has been put in server

//
//  D O  P L A Y E R S
//
//  Do the same thing to all connected players.  For each player,
//  'dofunc()' is called with 'self' pointing to the player.
//
void (void () dofunc) utils_do_players =
{
    local entity oldself;

    oldself = self;
    self = find(world, classname, "player");
    while (self)
    {
        if (self.style & ELOHIM_CONNECTED)
            dofunc();
        self = find(self, classname, "player");
    }
    self = oldself;
};

