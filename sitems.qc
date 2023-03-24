//
// SITEMS.QC
// manipula a variavel "sitems" do jogador
//

float(entity player) runeof =
{
        return player.sitems & 15;
};

void(entity player) removerune =
{
        player.sitems = player.sitems - (player.sitems & 15);
};

void(entity player, float runa) setrune =
{
        removerune (player);
        player.sitems = player.sitems + runa;
};

float(entity player) weapon2of =
{
        return (player.sitems & 240) / 16;
};

void(entity player) removeweapon2 =
{
        player.sitems = player.sitems - (player.sitems & 240);
};

void(entity player, float weapon2) setweapon2 =
{
        removeweapon2 (player);
        player.sitems = player.sitems + (weapon2 * 16);
};

