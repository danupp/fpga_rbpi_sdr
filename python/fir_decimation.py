import string

f = open('fir_decimation.txt', 'w')

k =[ 0,  -2,  -6,  -12,  -18,  -20,  -15,    0,    26,    65,    114,    171,    230,    284,    325,  
    345,    335,    289,    204,    78,  -86,  -280,  -492,  -707,  -906,  -1071,  -1180,  -1217,  
  -1165,  -1016,  -768,  -424,    0,    484,    998,    1507,    1972,    2354,    2613,    2717,  
    2640,    2369,    1902,    1252,    448,  -470,  -1446,  -2417,  -3314,  -4067,  -4611,  -4888,  
  -4857,  -4492,  -3792,  -2776,  -1490,    0,    1608,    3232,    4763,    6089,    7106,    7722,  
    7866,    7495,    6600,    5203,    3366,    1183,  -1222,  -3702,  -6096,  -8238,  -9969,  
  -11149,  -11665,  -11443,  -10455,  -8720,  -6311,  -3350,    0,    3537,    7039,    10271,  
    13005,    15035,    16189,    16345,    15441,    13481,    10542,    6766,    2360,  -2418,  -7273,  
  -11890,  -15956,  -19177,  -21304,  -22145,  -21585,  -19598,  -16247,  -11689,  -6168,    0,  
    6440,    12746,    18500,    23304,    26804,    28718,    28854,    27128,    23575,    18351,  
    11725,    4072,  -4154,  -12442,  -20257,  -27074,  -32412,  -35866,  -37141,  -36068,  
  -32628,  -26952,  -19323,  -10161,    0,    10539,    20790,    30079,    37772,    43313,    46266,  
    46348,    43450,    37652,    29227,    18624,    6451,  -6563,  -19607,  -31843,  -42454,  
  -50701,  -55972,  -57826,  -56028,  -50570,  -41681,  -29819,  -15647,    0,    16164,    31823,  
    45952,    57595,    65922,    70289,    70288,    65779,    56906,    44099,    28056,    9703,  
  -9855,  -29400,  -47677,  -63473,  -75697,  -83452,  -86102,  -83317,  -75107,  -61830,  
  -44181,  -23156,    0,    23869,    46943,    67718,    84793,    96961,    103291,    103200,  
    96498,    83415,    64593,    41063,    14191,  -14405,  -42946,  -69603,  -92612,  -110391,  
  -121642,  -125449,  -121341,  -109344,  -89985,  -64280,  -33682,    0,    34705,    68244,  
    98437,    123250,    140932,    150136,    150013,    140286,    121284,    93935,    59731,    20648,  
  -20966,  -62530,  -101386,  -134966,  -160959,  -177465,  -183131,  -177255,  -159845,  
  -131647,  -94120,  -49362,    0,    50961,    100318,    144864,    181598,    207915,    221788,  
    221918,    207836,    179962,    139608,    88925,    30795,  -31327,  -93616,  -152098,  -202906,  
  -242523,  -268016,  -277246,  -269029,  -243246,  -200888,  -144036,  -75767,    0,    78721,  
    155488,    225326,    283501,    325828,    348958,    350616,    329791,    286852,    223578,  
    143111,    49814,  -50946,  -153092,  -250180,  -335783,  -403895,  -449317,  -468022,  
  -457453,  -416761,  -346932,  -250828,  -133099,    0,    140908,    281145,    411774,    523916,  
    609281,    660699,    672615,    641514,    566253,    448284,    291733,    103350,  -107700,  
  -330177,  -551240,  -757025,  -933303,  -1066194,  -1142886,  -1152337,  -1085916,  -937945,  
  -706119,  -391778,    0,    460470,    977480,    1535897,    2118184,    2705107,    3276538,  
    3812310,    4293095,    4701251,    5021611,    5242156,    5354558,    5354558,    5242156,  
    5021611,    4701251,    4293095,    3812310,    3276538,    2705107,    2118184,    1535897,    977480,  
    460470,    0,  -391778,  -706119,  -937945,  -1085916,  -1152337,  -1142886,  -1066194]


for i in range (0,320):
    if k[i] >= 0:
        f.write('    "{0:024b}",\n'.format(k[i]))
    else:
        f.write('    "{0:024b}",\n'.format(16777216+k[i]))
#f.write( "%d\n" % k[i]

