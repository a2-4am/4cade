even_byte_bitmask = (0, 0, 1, 1, 2, 2, 3)
odd_byte_bitmask = (5, 5, 6, 6, 7, 7, 4)

def unique(coords):
    d = {}
    unique_coords = []
    for c in coords:
        if not d.get(c):
            unique_coords.append(c)
            d[c] = 1
    return unique_coords

def radial_multiply(unique_coords):
    q2 = [(279-x, y) for (x, y) in unique_coords]
    q2.reverse()
    q3 = [(279-x, 190-y) for (x, y) in unique_coords]
    q4 = [(x, 190-y) for (x, y) in unique_coords]
    q4.reverse()
    return unique([(x//2, y//2) for (x, y) in unique_coords + q2 + q3 + q4 if (x % 2 == 0) and (y % 4 == 0)])

def vals_1bit(unique_coords):
    unique_vals = []
    for x, y in unique_coords:
        aval = "$" + hex(y)[2:].rjust(2, "0").upper()
        bval = "%" + \
            bin(x%7)[2:].rjust(3, "0") + \
            bin(x//7)[2:].rjust(5, "0")
        unique_vals.append((aval, bval))
    return unique_vals

def vals_2bit(unique_coords):
    unique_vals = []
    for x, y in unique_coords:
        y = 191 - y
        aval = "$" + hex(y)[2:].rjust(2, "0").upper()
        byte = x//7
        if byte % 2 == 0:
            # high 3 bits are 0-3, low 5 bits are 0-19
            bval = "%" + bin(even_byte_bitmask[x % 7])[2:].rjust(3, "0") + bin(byte)[2:].rjust(5, "0")
            unique_vals.append((aval, bval))
            if x % 7 == 6:
                # this 2x2 block will be split across bytes, so add an extra coordinate pair with the adjacent byte and high 3 bits = 4
                bval = "%100" + bin(byte+1)[2:].rjust(5, "0") + ";"
                unique_vals.append((aval, bval))
        else:
            # high 3 bits are 5-7 or 4, low 5 bits are 0-19
            bval = "%" + bin(odd_byte_bitmask[x % 7])[2:].rjust(3, "0") + bin(byte)[2:].rjust(5, "0")
            unique_vals.append((aval, bval))
            if x % 7 == 6:
                # this 2x2 block will be split across bytes, so add an extra coordinate pair with the adjacent byte and high 3 bits = 3
                bval = "%011" + bin(byte+1)[2:].rjust(5, "0") + ";"
                unique_vals.append((aval, bval))
    return unique_vals

def vals_3bit(unique_coords):
    unique_vals = []
    for x, y in unique_coords:
        y = 63 - y//3
        byte = x//7
        if byte >= 32:
            byte -= 32
            y += 64
        aval = "$" + hex(y)[2:].rjust(2, "0").upper()
        if byte % 2 == 0:
            # high 3 bits are 0-3, low 5 bits are 0-19
            bval = "%" + bin(even_byte_bitmask[x % 7])[2:].rjust(3, "0") + bin(byte)[2:].rjust(5, "0")
            unique_vals.append((aval, bval))
            if x % 7 == 6:
                # this 2x2 block will be split across bytes, so add an extra coordinate pair with the adjacent byte and high 3 bits = 4
                bval = "%100" + bin(byte+1)[2:].rjust(5, "0") + ";"
                unique_vals.append((aval, bval))
        else:
            # high 3 bits are 5-7 or 4, low 5 bits are 0-19
            bval = "%" + bin(odd_byte_bitmask[x % 7])[2:].rjust(3, "0") + bin(byte)[2:].rjust(5, "0")
            unique_vals.append((aval, bval))
            if x % 7 == 6:
                # this 2x2 block will be split across bytes, so add an extra coordinate pair with the adjacent byte and high 3 bits = 3
                bval = "%011" + bin(byte+1)[2:].rjust(5, "0") + ";"
                unique_vals.append((aval, bval))
    return unique_vals

def ripple(unique_vals):
    z = len(unique_vals)
    ripple_vals = []
    for i, j, k, l in zip(range(z//4), range(z//4,z//2), range(z//2,z*3//4), range(z*3//4,z)):
        ripple_vals.append(unique_vals[i])
        ripple_vals.append(unique_vals[j])
        ripple_vals.append(unique_vals[k])
        ripple_vals.append(unique_vals[l])
    return ripple_vals

def halfripple(unique_vals):
    z = len(unique_vals)
    ripple_vals = []
    for i, j in zip(range(z//2), range(z//2,z)):
        ripple_vals.append(unique_vals[i])
        ripple_vals.append(unique_vals[j])
    return ripple_vals

def write(filename, vals):
    with open(filename, "w") as f:
        for aval, bval in vals:
            f.write("         !byte %s,%s\n" % (aval, bval))
