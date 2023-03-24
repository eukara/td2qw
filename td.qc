//Matador

void(entity client, string s1, string s2, string s3, string s4, string s5, string s6, string s7) centerprintx = #73;

//centerprints super-complicados do spinal

.float          statustime;             // status timer (for sbar refresh)
.string         messagetxt;             // holds a regular message
.float          messagetime;            // holds time to display
.float          messagebreaks;          // quantos "\n"s tem a msg, assim a status bar ainda fica visivel

void(entity e, string s, float breaks) ccenterprint =
{
        e.messagetxt = s;
        e.messagetime = time + 3;
        e.messagebreaks = breaks;
        e.statustime = 0;
};

void(entity e, string s, float breaks, float segundos) ceprint =
{
        e.messagetxt = s;
        e.messagetime = time + segundos;
        e.messagebreaks = breaks;
        e.statustime = 0;
};

void(entity e, string s) sprint =
{
        qw_sprint(e, PRINT_MEDIUM, s);
};
void(string s) bprint =
{
        qw_bprint(PRINT_MEDIUM, s);
};

//
//   td.qc
//   funcoes de POW das armas
//


//CAMPOS para RESPAWNER
.float player_force_respawn;



// nao tinha arquivo melhor pra socar essa funcao...
// retorna amount de max armor dado o armortype
//
float(entity player) MaxArmorForType =
{
    local float ma;

    if (player.armortype == 0.3) ma = 100; else
    if (player.armortype == 0.6) ma = 150; else
    if (player.armortype == 0.8) ma = 200; else
    if (player.armortype >= 0.9) ma = 250; else
    {
        player.armortype = 0.3; // bugfix... armadura verde inicial
        ma = 100;
    }

    return ma;
};


// v2.05 - MAX CELLS (qtde maxima de cells)
float MAX_CELLS = 100;  // ia botar 120 mas deixa assim

// funcaozinha q ajuda...
void() bound_self_ammo =
{
        // PATCH -- nao deixa ultrapassar ammos
        if (self.ammo_shells  > 100) self.ammo_shells  = 100;
        if (self.ammo_nails   > 200) self.ammo_nails   = 200;
        if (self.ammo_rockets > 100) self.ammo_rockets = 100;
        if (self.ammo_cells   > 100) self.ammo_cells   = 100;
};

float(entity player, float it_wpn) getpow =
{
        // V2.05 -> bugfix, POW=0 se nao possui a arma
        if (!(player.items & it_wpn)) return 0;

        local float ret, p;

        p = player.pow;

        ret = 0; // 1,2

        if (it_wpn == IT_SUPER_SHOTGUN)
           {
                if ((p & 1) > 0)  ret = ret + 1;
                if ((p & 2) > 0)  ret = ret + 2;
           }
        else if (it_wpn == IT_NAILGUN)
           {
                if ((p & 4) > 0)  ret = ret + 1;
                if ((p & 8) > 0)  ret = ret + 2;
           }
        else if (it_wpn == IT_SUPER_NAILGUN)
           {
                if ((p & 16) > 0)  ret = ret + 1;
                if ((p & 32) > 0)  ret = ret + 2;
           }
        else if (it_wpn == IT_GRENADE_LAUNCHER)
           {
                if ((p & 64) > 0)  ret = ret + 1;
                if ((p & 128) > 0)  ret = ret + 2;
           }
        else if (it_wpn == IT_ROCKET_LAUNCHER)
           {
                if ((p & 256) > 0)  ret = ret + 1;
                if ((p & 512) > 0)  ret = ret + 2;
           }
        else if (it_wpn == IT_LIGHTNING)
           {
                if ((p & 1024) > 0)  ret = ret + 1;
                if ((p & 2048) > 0)  ret = ret + 2;
           }

        return  ret;
};

float(entity player, float it_wpn) maxpower =
{
        local   float   ppow;

        ppow = getpow(player, it_wpn);

        if (ppow == 3) // ELUAN - TD 2.11 - limpeza geral no código (aqui era assignment used as truth value - bug do spinal mas essa função não era usada realmente, porque outra condição sempre falhava quando essa aqui era usada)
           return 1;
        else
            return 0;
};

void(entity player, float it_wpn) pow_upgrade =
{
        local   float   ppow;

        ppow = getpow(player, it_wpn);

        if (ppow == 3)
           return;      // max pow (4)

        local  float  fbase, fadd;

        if (it_wpn == IT_SUPER_SHOTGUN)         fbase = 1;
        else if (it_wpn == IT_NAILGUN)          fbase = 4;
        else if (it_wpn == IT_SUPER_NAILGUN)    fbase = 16;
        else if (it_wpn == IT_GRENADE_LAUNCHER) fbase = 64;
        else if (it_wpn == IT_ROCKET_LAUNCHER)  fbase = 256;
        else if (it_wpn == IT_LIGHTNING)        fbase = 1024;

        ppow = ppow + 1;

        if (ppow == 1)
           fadd = fbase;
        else if (ppow == 2)
           fadd = fbase * 2;
        else
            fadd = fbase + fbase * 2;

        player.pow = player.pow - (player.pow & (fbase + fbase * 2));
                   // retira pow antigo

        player.pow = player.pow + fadd;
                   // set novo pow
};

.float hook;
void() ClientDropStuff;
