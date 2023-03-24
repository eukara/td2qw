void() bound_other_ammo;

//
//  SWEAPONS.QC
//  ARMAS ESPECIAIS (unicas)
//

void() W_SetCurrentAmmo;
void() SUPER_weapon_touch =
{
    if (elohim_playmode & ELOHIM_MATCH_MODE && !(elohim_state & ELOHIM_MATCH_STARTED))
        return; //descomentar depois de testar...

        if (other.classname != "player")
           return;
        if (self.ltime > time)
           return;
        if (other.pow == -666)
		   return;
        if (other.health <= 0) //TD2.08: nao pega arma se morto
           return;

        if (weapon2of(other) > 0)
           {
                // v2.05 menos msg, menos lixo na tela
                //self.ltime = time + 2;
                //sprint(other, "Voce ja possui uma arma especial!\n");
                return;
           }

        // poe no inventorio
        setweapon2(other, self.items);
        other.items = other.items | IT_EXTRA_WEAPON;

        // PATCH -- MUNICAO MINIMA
        if (self.items == 1)
           {
                ceprint(other, "Arma Especial...\n\nÕÔÚÙÂÈÚÔÛ!\n\n\nTECLE 9 PARA USAR (impulse 20)\n\n", 7, 6);
                other.ammo_rockets = other.ammo_rockets +  15;
           }
        else if (self.items == 2)
           {
                ceprint(other, "Arma Especial...\n\n–ÈÂ‚ÔÌ‚Û!\n\n\nTECLE 9 PARA USAR (impulse 20)\n\n", 7, 6);
                other.ammo_rockets = other.ammo_rockets +  15;
           }
        else if (self.items == 3)
           {
                ceprint(other, "Arma Especial...\n\n”Ì·ÚÙ‚ÔÌ‚Û!\n\n\nTECLE 9 PARA USAR (impulse 20)\n\n", 7, 6);
                other.ammo_rockets = other.ammo_rockets +  20;
           }
        else if (self.items == 4)
           {
                ceprint(other, "Arma Especial...\n\n‘ÂÛÏ· „ÔÈÏ!\n\n\nTECLE 9 PARA USAR (impulse 20)\n\n", 7, 6);
                other.ammo_cells   = other.ammo_cells   +  20;
           }
        else if (self.items == 5)
           {
                ceprint(other, "Arma Especial...\n\n√»¡…Œ«’Œ!\n\n\nTECLE 9 PARA USAR (impulse 20)\n\n", 7, 6);
                other.ammo_shells  = other.ammo_shells  +  50;
           }

        bound_other_ammo ();  // patch

        other.messagetime = time + 4;
        other.statustime = 0;

	sound (other, CHAN_AUTO, "weapons/pkup.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	sprint (other, "Voce pegou o ");
	sprint (other, self.netname);
	sprint (other, "\n");

        remove(self);
};

void() KickSpecialWeapon;
void() SpecialWeaponThink =
{
        if (random() < 0.1)
           {
                local entity e;
                e = findradius (self.origin, 150);
                while (e)
                      {
                        if (e.classname == "sw")
                        if (e != self)
                           {
                                if (e.flags & FL_ONGROUND)
                                        e.think = KickSpecialWeapon;
                                else
                                    {
                                e.velocity_x = crandom() * 300;
                                e.velocity_y = crandom() * 300;
                                e.velocity_z = 300;
                                    }
                           }
                        e = e.chain;
                      }
           }

        self.effects = self.effects | EF_DIMLIGHT;

        // balaca treme-treme
        /*
        if (self.velocity == '0 0 0')
           {
                if (self.televec == '0 0 0')
                   self.televec = self.origin;
                else
                    {
                        local vector v;

                        v = self.televec;
                        v_x = v_x + crandom() * 4;
                        v_y = v_y + crandom() * 4;
                        v_z = v_z + crandom() * 4;
                        setorigin(self, v);
                    }
           }
        */

        if (time > self.health)
           self.think = KickSpecialWeapon;

        self.nextthink = time + 0.1;
};

void(float specialnum, vector org) TossSpecial =
{
        local entity weap;

        weap = spawn();
        weap.classname = "sw";
	weap.flags = FL_ITEM;		// make extra wide
	weap.solid = SOLID_TRIGGER;
	weap.movetype = MOVETYPE_TOSS;

        weap.touch = SUPER_weapon_touch;
        weap.health = time + 180;  // p/ daqui 180 segundos, kickspecialweaponzar

        weap.think = SpecialWeaponThink;
        weap.nextthink = time + 0.1;
        weap.televec = '0 0 0'; //patx

	weap.velocity_x = crandom() * 200;
        weap.velocity_y = crandom() * 200;
        weap.velocity_z = 300;

        weap.items = specialnum;
        weap.ltime = time + 1;

        weap.netname = "BUG!";

        if (weap.items == 1)
           { weap.netname = "Morteiros"; setmodel(weap, "progs/g_rock.mdl");}
        else if (weap.items == 2)
             { weap.netname = "Pipebombs"; setmodel(weap, "progs/g_rock.mdl");}
        else if (weap.items == 3)
             { weap.netname = "Smartbombs"; setmodel(weap, "progs/g_rock2.mdl");}
        else if (weap.items == 4)
             { weap.netname = "Tesla Coil"; setmodel(weap, "progs/g_light.mdl");
               // PATCH -- ops... ShareWareSux!
             }
        else if (weap.items == 5)
             { weap.netname = "Chaingun"; setmodel(weap, "progs/g_nail2.mdl"); }

        //bprint("TOSS SPECIAL --> ");
        //bprint(weap.netname);
        //bprint("\n");

        setsize (weap, '-16 -16 0', '16 16 56');
        setorigin(weap, org);
};

// coloca arma especial na fase
void() KickSpecialWeapon =
{
        local entity spot;

        spot = find(world, classname, "info_player_deathmatch");
        while (random() > 0.05)
                spot = find (spot, classname, "info_player_deathmatch");

        TossSpecial (self.items, spot.origin);

        remove(self);
};

// joga fora arma especial
float() W_BestWeapon;
void() TRASH_Special =
{
        local float w2;
        w2 = weapon2of (self);
        if (w2 == 0) return;

        sprint(self, "Jogando ARMA ESPECIAL fora...\n");
        stuffcmd(self, "bf\n");

        removeweapon2 (self);
        self.items = self.items - (self.items & IT_EXTRA_WEAPON);

        // se tava com a pipebomb com bomba largada,
        // remove bomba
        if (w2 == 2)
           {
                local entity e;
                e = find(world, classname, "td_temp");
                while (e)
                  {
                        if (e.owner == self)
                        if (e.magic == 102) // pipebomb id
                           remove (e);
                        e = find(e, classname, "td_temp");
                  }
           }

        // se tava usando a special, entao troca
        if (self.weapon == IT_EXTRA_WEAPON)
           {
	        self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
           }

        // 10s pra botar em jogo
        local entity armaesp;
        armaesp = spawn();
        armaesp.think = KickSpecialWeapon;
        armaesp.nextthink = time + 10;
        armaesp.items = w2;

        self.statustime = 0;

};