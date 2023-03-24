//
//  Strings.qc
//
//  A bunch of routines for returning various strings.
//  Several routines were inspired by the clanring server mod.
//

//
//  F T O S
//
//  Some numbers have been hard-coded to avoid the problems associated with
//  a single ftos buffer.
//
string (float n) strings_ftos =
{
    if (n == 1)
        return "1 ";
    else if (n == 2)
        return "2 ";
    else if (n == 3)
        return "3 ";
    else if (n == 4)
        return "4 ";
    else if (n == 5)
        return "5 ";
    else if (n == 6)
        return "6 ";
    else if (n == 7)
        return "7 ";
    else if (n == 8)
        return "8 ";
    else if (n == 9)
        return "9 ";
    else if (n == 10)
        return "10";
    else if (n == 11)
        return "11";
    else if (n == 12)
        return "12";
    else if (n == 13)
        return "13";
    else if (n == 14)
        return "14";
    else if (n == 15)
        return "15";
    else if (n == 20)
        return "20";
    else if (n == 25)
        return "25";
    else if (n == 30)
        return "30";
    else
        return "???";
};

//
//  F T O S  G O L D
//
//  Return some gold number strings.
//
string (float n) strings_ftos_gold =
{
    if (n == 0)
        return "’";
    else if (n == 1)
        return "“";
    else if (n == 2)
        return "”";
    else if (n == 3)
        return "•";
    else if (n == 4)
        return "–";
    else if (n == 5)
        return "—";
    else if (n == 6)
        return "˜";
    else if (n == 7)
        return "™";
    else if (n == 8)
        return "š";
    else if (n == 9)
        return "›";
    else
        return "?";
};

//
//  G E T  T E A M N A M E
//
//  Return the colour string corresponding to a given team.
//
string (float num) strings_get_teamname =
{
    if (num == 1)
        return "Brown";
    else if (num == 2)
        return "Light Blue";
    else if (num == 3)
        return "Green";
    else if (num == 4)
        return "Red";
    else if (num == 5)
        return "Olive";
    else if (num == 6)
        return "Gold";
    else if (num == 7)
        return "Flesh";
    else if (num == 8)
        return "Lavender";
    else if (num == 9)
        return "Purple";
    else if (num == 10)
        return "Beige";
    else if (num == 11)
        return "Aqua";
    else if (num == 12)
        return "Yellow";
    else if (num == 13)
        return "Blue";
    else
        return "????"; // shouldn't happen
};

//
//  G E T  T E A M N A M E 2
//
//  Return the colour string corresponding to a given team.
//  The string contains EXACTLY 10 characters.
//
string (float num) strings_get_teamname2 =
{
    if (num == 1)
        return "Brown     ";
    else if (num == 2)
        return "Light Blue";
    else if (num == 3)
        return "Green     ";
    else if (num == 4)
        return "Red       ";
    else if (num == 5)
        return "Olive     ";
    else if (num == 6)
        return "Gold      ";
    else if (num == 7)
        return "Flesh     ";
    else if (num == 8)
        return "Lavender  ";
    else if (num == 9)
        return "Purple    ";
    else if (num == 10)
        return "Beige     ";
    else if (num == 11)
        return "Aqua      ";
    else if (num == 12)
        return "Yellow    ";
    else if (num == 13)
        return "Blue      ";
    else
        return "????      "; // shouldn't happen
};

//
//  G E T  M A P N A M E
//
//  Return the nth map name.
//
string (float mapnum) strings_get_mapname =
{
    if (mapnum < 10)
    {
        if (mapnum == 0)
            return "start";
        else if (mapnum == 1)
            return "e1m1";
        else if (mapnum == 2)
            return "e1m2";
        else if (mapnum == 3)
            return "e1m3";
        else if (mapnum == 4)
            return "e1m4";
        else if (mapnum == 5)
            return "e1m5";
        else if (mapnum == 6)
            return "e1m6";
        else if (mapnum == 7)
            return "e1m7";
        else if (mapnum == 8)
            return "nitrodm2";
        else
            return "gmdm1";
    }
    else if (mapnum < 20)
    {
        if (mapnum == 10)
            return "e2m2";
        else if (mapnum == 11)
            return "e2m3";
        else if (mapnum == 12)
            return "ultrav";
        else if (mapnum == 13)
            return "dma8";
        else if (mapnum == 14)
            return "bravado";
        else if (mapnum == 15)
            return "rash";
        else if (mapnum == 16)
            return "e3m1";
        else if (mapnum == 17)
            return "hex";
        else if (mapnum == 18)
            return "e3m3";
        else
            return "e3m4";
    }
    else if (mapnum < 30)
    {
        if (mapnum == 20)
            return "e3m5";
        else if (mapnum == 21)
            return "rock";
        else if (mapnum == 22)
            return "e3m7";
        else if (mapnum == 23)
            return "e4m1";
        else if (mapnum == 24)
            return "e4m2";
        else if (mapnum == 25)
            return "e4m3";
        else if (mapnum == 26)
            return "monsoon";
        else if (mapnum == 27)
            return "ztndm3";
        else if (mapnum == 28)
            return "ztndm6";
        else
            return "q1edge";
    }
    else if (mapnum < 40)
    {
        if (mapnum == 30)
            return "aerowalk";
        else if (mapnum == 31)
            return "end";
        else if (mapnum == 32)
            return "dm1";
        else if (mapnum == 33)
            return "dm2";
        else if (mapnum == 34)
            return "dm3";
        else if (mapnum == 35)
            return "dm4";
        else if (mapnum == 36)
            return "dm5";
        else if (mapnum == 37)
            return "dm6";
        else if (mapnum == 38)
            return "start0";
        else
            return "dm4";
    }
    else
        return array_get_user_map(mapnum - 40);
};

//
//  G E T  M O D E
//
//  Returns "Normal", "Practice", or "Match".
//
string (float mode) strings_get_mode =
{
    if (mode == 0)
        return "Normal";
    else if (mode == 1)
        return "Practice";
    else
        return "Match";
};
