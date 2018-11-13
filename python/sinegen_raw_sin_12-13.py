import math

f = open('raw_cos_quarter_unsigned__12-13.mif', 'w')

f.write("DEPTH = 4096;\nWIDTH = 13;\nADDRESS_RADIX = DEC;\nDATA_RADIX = DEC;\n\n")
f.write("CONTENT\nBEGIN\n")

for A in range(0,4096):
    val_c = 8191*math.sin((float(A)/4096)*math.pi/2)
    f.write("%s  : %d;\n" % (A,round(val_c)))

f.write("END;") 

