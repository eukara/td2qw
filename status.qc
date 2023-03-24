//
//  STATUS.QC
//    Status bar do jogador
//
//  mostra arma, magia e runa
//
//

void() StatusThink =
{
    if (self.style & ELOHIM_SETTING_OPTIONS)
        return;

        if (self.messagetime == 66996699)
           {
                stuffcmd (self, "scr_centertime 20\n");
//                stuffcmd (self, "bind 9 \"impulse 20\"\n");
//                stuffcmd (self, "bind 0 \"impulse 21\"\n");
				  stuffcmd (self, "alias \"trashrune\" \"impulse 22\"\n");
				  stuffcmd (self, "alias \"trashsw\" \"impulse 23\"\n");
				  stuffcmd (self, "bind 9 \"impulse 20\"\n");
				  stuffcmd (self, "alias \"swep\" \"impulse 20\"\n");
 	              stuffcmd (self, "bind 0 \"yes\"\n");

                self.messagetime = 66996691;
                self.statustime = time + 1.5;
           }
        else if (self.messagetime == 66996691)
           {
                stuffcmd (self, "scr_centertime 20\n");
//                stuffcmd (self, "bind 9 \"impulse 20\"\n");
//                stuffcmd (self, "bind 0 \"impulse 21\"\n");
				  stuffcmd (self, "alias \"trashrune\" \"impulse 22\"\n");
				  stuffcmd (self, "alias \"trashsw\" \"impulse 23\"\n");
				  stuffcmd (self, "bind 9 \"impulse 20\"\n");
				  stuffcmd (self, "alias \"swep\" \"impulse 20\"\n");
 	              stuffcmd (self, "bind 0 \"yes\"\n");


                self.messagetime = time + 20;
                self.statustime = time + 1.5;
           }
        else
               self.statustime = time + 7 + random() * 3;

        //
        //  VOTACAO ATIVA: mostra mensagens em cima das outas
        //

        if (elohim_request)
           {
           	local float mes;
                if (elohim_request.owner == self)
                   {
                        local float vsim;
                        vsim = elohim_request.frags;
                        // n√£o d√° pra calcular quantos votos precisamos porque votos no vote.qc t√™m pesos - TODO: cancelar votos de observers?

                        mes = 1;

			if (vsim == 1) self.messagetxt = "\n\n\n\n\n\n\n\n\n\nVotos a favor: 1"; else
			if (vsim == 2) self.messagetxt = "\n\n\n\n\n\n\n\n\n\nVotos a favor: 2"; else
			if (vsim == 3) self.messagetxt = "\n\n\n\n\n\n\n\n\n\nVotos a favor: 3"; else
			if (vsim == 4) self.messagetxt = "\n\n\n\n\n\n\n\n\n\nVotos a favor: 4"; else
			if (vsim == 5) self.messagetxt = "\n\n\n\n\n\n\n\n\n\nVotos a favor: 5"; else
			if (vsim == 6) self.messagetxt = "\n\n\n\n\n\n\n\n\n\nVotos a favor: 6"; else
			if (vsim == 7) self.messagetxt = "\n\n\n\n\n\n\n\n\n\nVotos a favor: 7"; else
			if (vsim == 8) self.messagetxt = "\n\n\n\n\n\n\n\n\n\nVotos a favor: 8"; else
			if (vsim == 9) self.messagetxt = "\n\n\n\n\n\n\n\n\n\nVotos a favor: 9"; else
			mes = 0;

                        if (mes)
                           {
                                self.messagebreaks = 10;
                                self.messagetime = time + 10;
                           }
                   }
                else if (!(self.style & ELOHIM_YES))
                    {
                    	mes = 1;
                    	// gambiarra porque o centerprint do quake vai s√≥ at√© 7 par√¢metros!
                    	// j√° temos os strings completos no elohim_request, mas temos que ficar recriando aqui por causa dessa limita√ß√£o
                    	if (elohim_request.use == admin_change_level)
                    	{
                    		if (elohim_request.map == "start0") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: START0 Tecla \"0\" = SIM!"; else
                    		if (elohim_request.map == "dm4") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: DM4 Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "start") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: START  Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "end") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: END    Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "e1m1") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: E1M1   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "e1m2") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: E1M2   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "e1m3") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: E1M3   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "e1m4") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: E1M4   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "e1m5") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: E1M5   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "e1m6") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: E1M6   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "e1m7") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: E1M7   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "nitrodm2") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: NITRODM2   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "gmdm1") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: GMDM1   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "e2m2") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: E2M2   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "e2m3") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: E2M3   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "ultrav") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: ULTRAV   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "dma8") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: DMA8   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "bravado") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: BRAVADO   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "rash") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: RASH   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "e3m1") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: E3M1   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "hex") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: HEX   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "e3m3") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: E3M3   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "e3m4") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: E3M4   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "e3m5") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: E3M5   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "rock") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: ROCK   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "e3m7") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: E3M7   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "e4m1") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: E4M1   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "e4m2") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: E4M2   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "e4m3") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: E4M3   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "monsoon") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: MONSOON   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "ztndm3") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: ZTNDM3   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "ztndm6") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: ZTNDM6   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "q1edge") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: Q1EDGE   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "aerowalk") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: AEROWALK   Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "dm1") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: DM1    Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "dm2") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: DM2    Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "dm3") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: DM3    Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "dm4") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: DM4    Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "dm5") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: DM5    Tecla \"0\" = SIM!"; else
				if (elohim_request.map == "dm6") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nTroca de mapa: DM6    Tecla \"0\" = SIM!"; else
				{
					bprint3("Votacao: mapa desconhecido! ", elohim_request.map, "\n");
					mes = 0;
				}
			} else
                        if (elohim_request.use == match_unlock) self.messagetxt = "\n\n\n\n\n\n\n\n\n\nAceitar novos players Tecla \"0\" = SIM!"; else
                        if (elohim_request.use == match_pause) self.messagetxt = "\n\n\n\n\n\n\n\n\n\nPausar a partida      Tecla \"0\" = SIM!"; else
                        if (elohim_request.use == match_start_timer) self.messagetxt = "\n\n\n\n\n\n\n\n\n\nIniciar o timer       Tecla \"0\" = SIM!"; else
                        if (elohim_request.use == match_unpause) self.messagetxt = "\n\n\n\n\n\n\n\n\n\nDespausar a partida   Tecla \"0\" = SIM!"; else
                        if (elohim_request.use == admin_set_mode)
                        {
                        	if (elohim_request.map == "Normal") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nSetar modo NORMAL     Tecla \"0\" = SIM!"; else
                        	if (elohim_request.map == "Practice") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nSetar modo PRACTICE   Tecla \"0\" = SIM!"; else
                        	if (elohim_request.map == "Match") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nSetar modo MATCH      Tecla \"0\" = SIM!"; else
                        	{
					bprint3("Votacao: modo desconhecido! ", elohim_request.map, "\n");
					mes = 0;
				}
                        } else
                        if (elohim_request.use == admin_set_timelimit)
                        {
                        	if (elohim_request.map == "5") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nSetar timelimit = 5   Tecla \"0\" = SIM!"; else
                        	if (elohim_request.map == "10") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nSetar timelimit = 10  Tecla \"0\" = SIM!"; else
                        	if (elohim_request.map == "15") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nSetar timelimit = 15  Tecla \"0\" = SIM!"; else
                        	if (elohim_request.map == "20") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nSetar timelimit = 20  Tecla \"0\" = SIM!"; else
                        	if (elohim_request.map == "25") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nSetar timelimit = 25  Tecla \"0\" = SIM!"; else
                        	if (elohim_request.map == "30") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nSetar timelimit = 30  Tecla \"0\" = SIM!"; else
                        	{
					bprint3("Votacao: timelimit desconhecido! ", elohim_request.map, "\n");
					mes = 0;
				}
                        } else
                        if (elohim_request.use == admin_set_gibs)
                        {
                        	if (elohim_request.map == "'disabled'") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nSetar gibs = disabled Tecla \"0\" = SIM!"; else
                        	if (elohim_request.map == "'low'") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nSetar gibs = low      Tecla \"0\" = SIM!"; else
                        	if (elohim_request.map == "'high'") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nSetar gibs = high     Tecla \"0\" = SIM!"; else
                        	{
					bprint3("Votacao: quantidade de gibs desconhecida! ", elohim_request.map, "\n");
					mes = 0;
				}
			} else
                        if (elohim_request.use == admin_set_quad)
                        {
                        	if (elohim_request.wad == "ativar") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nAtivar quad           Tecla \"0\" = SIM!"; else
                        	if (elohim_request.wad == "desativar") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nDesativar quad        Tecla \"0\" = SIM!"; else
                        	{
					bprint3("Votacao: estado do quad desconhecido! ", elohim_request.wad, "\n");
					mes = 0;
				}
			} else
                        if (elohim_request.use == admin_set_pent)
                        {
                        	if (elohim_request.wad == "ativar") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nAtivar pentagrama     Tecla \"0\" = SIM!"; else
                        	if (elohim_request.wad == "desativar") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nDesativar pentagrama  Tecla \"0\" = SIM!"; else
                        	{
					bprint3("Votacao: estado do pentagrama desconhecido! ", elohim_request.wad, "\n");
					mes = 0;
				}
			} else
                        if (elohim_request.use == admin_set_ring)
                        {
                        	if (elohim_request.wad == "ativar") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nAtivar ring           Tecla \"0\" = SIM!"; else
                        	if (elohim_request.wad == "desativar") self.messagetxt = "\n\n\n\n\n\n\n\n\n\nDesativar ring        Tecla \"0\" = SIM!"; else
                        	{
					bprint3("Votacao: estado do ring of shadows desconhecido! ", elohim_request.wad, "\n");
					mes = 0;
				}
			} else
			{
				bprint4("votacao desconhecida! ", elohim_request.wad, elohim_request.map, "\n");
				mes = 0;
			}

			if (mes)
			{
				self.messagebreaks = 10;
				self.messagetime = time + 10;
			}
                    }
           }

        local string powstr;

        // PATCH -- status do zumbi

        if (self.pow == -666)
           {
                local float len;
                len = vlen(self.enemy.origin - self.origin);
                powstr = ftos(len);

                if (self.messagebreaks == 0)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n\n\n\n", "", "     Corra atras do seu assassino!      \n", self.enemy.netname, "          dist. ", powstr);
                else if (self.messagebreaks == 1)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n\n\n", "", "     Corra atras do seu assassino!      \n", self.enemy.netname, "          dist. ", powstr);
                else if (self.messagebreaks == 2)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n\n", "", "     Corra atras do seu assassino!      \n", self.enemy.netname, "          dist. ", powstr);
                else if (self.messagebreaks == 3)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n", "", "     Corra atras do seu assassino!      \n", self.enemy.netname, "          dist. ", powstr);
                else if (self.messagebreaks == 4)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n", "", "     Corra atras do seu assassino!      \n", self.enemy.netname, "          dist. ", powstr);
                else if (self.messagebreaks == 5)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n", "", "     Corra atras do seu assassino!      \n", self.enemy.netname, "          dist. ", powstr);
                else if (self.messagebreaks == 6)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n", "", "     Corra atras do seu assassino!      \n", self.enemy.netname, "          dist. ", powstr);
                else if (self.messagebreaks == 7)
                   centerprintx(self, self.messagetxt, "\n\n\n\n", "", "     Corra atras do seu assassino!      \n", self.enemy.netname, "          dist. ", powstr);
                else if (self.messagebreaks == 8)
                   centerprintx(self, self.messagetxt, "\n\n\n", "", "     Corra atras do seu assassino!      \n", self.enemy.netname, "          dist. ", powstr);
                else if (self.messagebreaks == 9)
                   centerprintx(self, self.messagetxt, "\n\n", "", "     Corra atras do seu assassino!      \n", self.enemy.netname, "          dist. ", powstr);
                else if (self.messagebreaks == 10)
                   centerprintx(self, self.messagetxt, "\n", "", "     Corra atras do seu assassino!      \n", self.enemy.netname, "          dist. ", powstr);
                else if (self.messagebreaks == 11)
                   centerprintx(self, self.messagetxt, "", "", "     Corra atras do seu assassino!      \n", self.enemy.netname, "          dist. ", powstr);

                return;
           }

        // ENDPATCH zumbi

        local float weapon_pow;
        weapon_pow = getpow(self, self.weapon);

        if (self.weapon == IT_AXE)
             powstr = "                ";
        else if (self.weapon == IT_SHOTGUN)
             powstr = "Uzi             ";
        else if (self.weapon == IT_SUPER_SHOTGUN)
             {
                if (weapon_pow == 0) powstr = "Shotgun ê1  ë   "; else
                if (weapon_pow == 1) powstr = "Shotgun ê 2 ë   "; else
                if (weapon_pow == 2) powstr = "Shotgun ê  3ë   "; else
                if (weapon_pow == 3) powstr = "Shotgun êMAXë   ";
             }
        else if (self.weapon == IT_NAILGUN)
             {
                if (weapon_pow == 0) powstr = "Flame   ê1  ë   "; else
                if (weapon_pow == 1) powstr = "Flame   ê 2 ë   "; else
                if (weapon_pow == 2) powstr = "Flame   ê  3ë   "; else
                if (weapon_pow == 3) powstr = "Flame   êMAXë   ";
             }
        else if (self.weapon == IT_SUPER_NAILGUN)
             {
                if (weapon_pow == 0) powstr = "Nailgun ê1  ë   "; else
                if (weapon_pow == 1) powstr = "Nailgun ê 2 ë   "; else
                if (weapon_pow == 2) powstr = "Nailgun ê  3ë   "; else
                if (weapon_pow == 3) powstr = "Nailgun êMAXë   ";
             }
        else if (self.weapon == IT_GRENADE_LAUNCHER)
             {
                if (weapon_pow == 0) powstr = "Grenade ê1  ë   "; else
                if (weapon_pow == 1) powstr = "Grenade ê 2 ë   "; else
                if (weapon_pow == 2) powstr = "Grenade ê  3ë   "; else
                if (weapon_pow == 3) powstr = "Grenade êMAXë   ";
             }
        else if (self.weapon == IT_ROCKET_LAUNCHER)
             {
                if (weapon_pow == 0) powstr = "Rocket  ê1  ë   "; else
                if (weapon_pow == 1) powstr = "Rocket  ê 2 ë   "; else
                if (weapon_pow == 2) powstr = "Rocket  ê  3ë   "; else
                if (weapon_pow == 3) powstr = "Rocket  êMAXë   ";
             }
        else if (self.weapon == IT_LIGHTNING)
             {
                if (weapon_pow == 0) powstr = "Thunder ê1  ë   "; else
                if (weapon_pow == 1) powstr = "Thunder ê 2 ë   "; else
                if (weapon_pow == 2) powstr = "Thunder ê  3ë   "; else
                if (weapon_pow == 3) powstr = "Thunder êMAXë   ";
             }
        else if (self.weapon == IT_EXTRA_WEAPON)
             {
                local float sw;
                sw = weapon2of(self);

                if (sw == 1) powstr = "Morteiros       ";
                else if (sw == 2) powstr = "Pipebombs       ";
                else if (sw == 3) powstr = "Smartbombs      ";
                else if (sw == 4)
                     {
                        if (self.tesla == 0)      powstr = "Tesla Coil      ";
                        else if (self.tesla < 10) powstr = "Tesla Coil ããããã";
                        else if (self.tesla < 20) powstr = "Tesla Coil ãããã";
                        else if (self.tesla < 30) powstr = "Tesla Coil ããã";
                        else if (self.tesla < 40) powstr = "Tesla Coil ãã";
                        else if (self.tesla < 50) powstr = "Tesla Coil ã";
                        else if (self.tesla < 55) powstr = "Tesla Coil ";
                        else                      powstr = " WARNING! ";
                        /*
                        if (self.tesla == 0)      powstr = "Tesla Coil ããããã";
                        else if (self.tesla < 5)  powstr = "Tesla Coil 
ãããã";
                        else if (self.tesla < 10) powstr = "Tesla Coil 

ããã";
                        else if (self.tesla < 20) powstr = "Tesla Coil 


ãã";
                        else if (self.tesla < 30) powstr = "Tesla Coil 



ã";
                        else if (self.tesla < 40) powstr = "Tesla Coil 




";
                        else                      powstr = " WARNING!  




";
                        */
                     }
                else if (sw == 5) powstr = "Chaingun        ";
             }
        else
	     powstr = "                ";

        local string tiziu;

        if (self.ltime <= time)
           tiziu = "   ";
        else
            {
                local float chtime;
                chtime = ceil(self.ltime - time);

                if (chtime < 5)
                   self.statustime = time + 1;
                else if (chtime < 10)
                     self.statustime = time + (chtime - 5);

                //tiziu = ftos(chtime);

                if (chtime == 1) tiziu = " 1 "; else
                if (chtime == 2) tiziu = " 2 "; else
                if (chtime == 3) tiziu = " 3 "; else
                if (chtime == 4) tiziu = " 4 "; else
                if (chtime == 5) tiziu = " 5 "; else
                if (chtime == 6) tiziu = " 6 "; else
                if (chtime == 7) tiziu = " 7 "; else
                if (chtime == 8) tiziu = " 8 "; else
                if (chtime == 9) tiziu = " 9 "; else
                if (chtime == 10) tiziu = "10 "; else
                if (chtime == 11) tiziu = "11 "; else
                if (chtime == 12) tiziu = "12 "; else
                if (chtime == 13) tiziu = "13 "; else
                if (chtime == 14) tiziu = "14 "; else
                if (chtime == 15) tiziu = "15 "; else
                if (chtime == 16) tiziu = "16 "; else
                if (chtime == 17) tiziu = "17 "; else
                if (chtime == 18) tiziu = "18 "; else
                if (chtime == 19) tiziu = "19 "; else
                if (chtime == 20) tiziu = "20 "; else
                if (chtime == 21) tiziu = "21 "; else
                if (chtime == 22) tiziu = "22 "; else
                if (chtime == 23) tiziu = "23 "; else
                if (chtime == 24) tiziu = "24 "; else
                if (chtime == 25) tiziu = "25 "; else
                if (chtime == 26) tiziu = "26 "; else
                if (chtime == 27) tiziu = "27 "; else
                if (chtime == 28) tiziu = "28 "; else
                if (chtime == 29) tiziu = "29 "; else
                if (chtime == 30) tiziu = "30 "; else
                if (chtime == 31) tiziu = "31 "; else
                if (chtime == 32) tiziu = "32 "; else
                if (chtime == 33) tiziu = "33 "; else
                if (chtime == 34) tiziu = "34 "; else
                if (chtime == 35) tiziu = "35 "; else
                if (chtime == 36) tiziu = "36 "; else
                if (chtime == 37) tiziu = "37 "; else
                if (chtime == 38) tiziu = "38 "; else
                if (chtime == 39) tiziu = "39 "; else
                if (chtime == 40) tiziu = "40 "; else
                if (chtime == 41) tiziu = "41 "; else
                if (chtime == 42) tiziu = "42 "; else
                if (chtime == 43) tiziu = "43 "; else
                if (chtime == 44) tiziu = "44 "; else
                if (chtime == 45) tiziu = "45 "; else
                if (chtime == 46) tiziu = "46 "; else
                if (chtime == 47) tiziu = "47 "; else
                if (chtime == 48) tiziu = "48 "; else
                if (chtime == 49) tiziu = "49 "; else
                if (chtime == 50) tiziu = "50 "; else
                if (chtime == 51) tiziu = "51 "; else
                if (chtime == 52) tiziu = "52 "; else
                if (chtime == 53) tiziu = "53 "; else
                if (chtime == 54) tiziu = "54 "; else
                if (chtime == 55) tiziu = "55 "; else
                if (chtime == 56) tiziu = "56 "; else
                if (chtime == 57) tiziu = "57 "; else
                if (chtime == 58) tiziu = "58 "; else
                if (chtime == 59) tiziu = "59 "; else
                if (chtime == 60) tiziu = "60 ";
            }

        if (runeof(self) == 1)
           {
                if (self.messagebreaks == 0)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n\n\n\n", "                              √·ÌıÊÏ·ÁÂÌ\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 1)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n\n\n", "                              √·ÌıÊÏ·ÁÂÌ\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 2)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n\n", "                              √·ÌıÊÏ·ÁÂÌ\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 3)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n", "                              √·ÌıÊÏ·ÁÂÌ\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 4)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n", "                              √·ÌıÊÏ·ÁÂÌ\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 5)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n", "                              √·ÌıÊÏ·ÁÂÌ\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 6)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n", "                              √·ÌıÊÏ·ÁÂÌ\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 7)
                   centerprintx(self, self.messagetxt, "\n\n\n\n", "                              √·ÌıÊÏ·ÁÂÌ\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 8)
                   centerprintx(self, self.messagetxt, "\n\n\n", "                              √·ÌıÊÏ·ÁÂÌ\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 9)
                   centerprintx(self, self.messagetxt, "\n\n", "                              √·ÌıÊÏ·ÁÂÌ\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 10)
                   centerprintx(self, self.messagetxt, "\n", "                              √·ÌıÊÏ·ÁÂÌ\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 11)
                   centerprintx(self, self.messagetxt, "", "                              √·ÌıÊÏ·ÁÂÌ\n", powstr, "             ", tiziu, self.magicstr);
           }
        else if (runeof(self) == 2)
           {
                if (self.messagebreaks == 0)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n\n\n\n", "                                ¡ÚÌ·‰ıÚ·\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 1)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n\n\n", "                                ¡ÚÌ·‰ıÚ·\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 2)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n\n", "                                ¡ÚÌ·‰ıÚ·\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 3)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n", "                                ¡ÚÌ·‰ıÚ·\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 4)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n", "                                ¡ÚÌ·‰ıÚ·\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 5)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n", "                                ¡ÚÌ·‰ıÚ·\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 6)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n", "                                ¡ÚÌ·‰ıÚ·\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 7)
                   centerprintx(self, self.messagetxt, "\n\n\n\n", "                                ¡ÚÌ·‰ıÚ·\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 8)
                   centerprintx(self, self.messagetxt, "\n\n\n", "                                ¡ÚÌ·‰ıÚ·\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 9)
                   centerprintx(self, self.messagetxt, "\n\n", "                                ¡ÚÌ·‰ıÚ·\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 10)
                   centerprintx(self, self.messagetxt, "\n", "                                ¡ÚÌ·‰ıÚ·\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 11)
                   centerprintx(self, self.messagetxt, "", "                                ¡ÚÌ·‰ıÚ·\n", powstr, "             ", tiziu, self.magicstr);
           }
        else if (runeof(self) == 3)
           {
                if (self.messagebreaks == 0)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n\n\n\n", "                                   ‘ıÚ‚Ô\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 1)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n\n\n", "                                   ‘ıÚ‚Ô\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 2)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n\n", "                                   ‘ıÚ‚Ô\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 3)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n", "                                   ‘ıÚ‚Ô\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 4)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n", "                                   ‘ıÚ‚Ô\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 5)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n", "                                   ‘ıÚ‚Ô\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 6)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n", "                                   ‘ıÚ‚Ô\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 7)
                   centerprintx(self, self.messagetxt, "\n\n\n\n", "                                   ‘ıÚ‚Ô\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 8)
                   centerprintx(self, self.messagetxt, "\n\n\n", "                                   ‘ıÚ‚Ô\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 9)
                   centerprintx(self, self.messagetxt, "\n\n", "                                   ‘ıÚ‚Ô\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 10)
                   centerprintx(self, self.messagetxt, "\n", "                                   ‘ıÚ‚Ô\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 11)
                   centerprintx(self, self.messagetxt, "", "                                   ‘ıÚ‚Ô\n", powstr, "             ", tiziu, self.magicstr);
           }
        else if (runeof(self) == 4)
           {
                if (self.messagebreaks == 0)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n\n\n\n", "                             “ÂÁÂÓÂÚ·„·Ô\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 1)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n\n\n", "                             “ÂÁÂÓÂÚ·„·Ô\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 2)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n\n", "                             “ÂÁÂÓÂÚ·„·Ô\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 3)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n", "                             “ÂÁÂÓÂÚ·„·Ô\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 4)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n", "                             “ÂÁÂÓÂÚ·„·Ô\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 5)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n", "                             “ÂÁÂÓÂÚ·„·Ô\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 6)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n", "                             “ÂÁÂÓÂÚ·„·Ô\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 7)
                   centerprintx(self, self.messagetxt, "\n\n\n\n", "                             “ÂÁÂÓÂÚ·„·Ô\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 8)
                   centerprintx(self, self.messagetxt, "\n\n\n", "                             “ÂÁÂÓÂÚ·„·Ô\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 9)
                   centerprintx(self, self.messagetxt, "\n\n", "                               “ÂÁÂÓÂÚ·„·Ô\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 10)
                   centerprintx(self, self.messagetxt, "\n", "                               “ÂÁÂÓÂÚ·„·Ô\n", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 11)
                   centerprintx(self, self.messagetxt, "", "                               “ÂÁÂÓÂÚ·„·Ô\n", powstr, "             ", tiziu, self.magicstr);
           }
        else
           {
                if (self.messagebreaks == 0)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n\n\n\n\n", "", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 1)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n\n\n\n", "", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 2)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n\n\n", "", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 3)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n\n", "", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 4)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n\n", "", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 5)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n\n", "", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 6)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n\n", "", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 7)
                   centerprintx(self, self.messagetxt, "\n\n\n\n\n", "", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 8)
                   centerprintx(self, self.messagetxt, "\n\n\n\n", "", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 9)
                   centerprintx(self, self.messagetxt, "\n\n\n", "", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 10)
                   centerprintx(self, self.messagetxt, "\n\n", "", powstr, "             ", tiziu, self.magicstr);
                else if (self.messagebreaks == 11)
                   centerprintx(self, self.messagetxt, "\n", "", powstr, "             ", tiziu, self.magicstr);
           }
};
