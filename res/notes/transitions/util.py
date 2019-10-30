def unique(coords):
    d = {}
    unique_coords = []
    for c in coords:
        if not d.get(c):
            unique_coords.append(c)
            d[c] = 1
    return unique_coords

even_byte_bitmask = (0, 0, 1, 1, 2, 2, 3)
odd_byte_bitmask = (5, 5, 6, 6, 7, 7, 4)
def vals_2bit(unique_coords):
    unique_vals = []
    for x, y in unique_coords:
        y = 191 - y
        aval = "$" + hex(y)[2:].rjust(2, "0").upper()
        byte = x//7
        if byte % 2 == 0:
            # high 3 bits are 0-3, low 5 bits are 0-39
            bval = "%" + bin(even_byte_bitmask[x % 7])[2:].rjust(3, "0") + bin(byte)[2:].rjust(5, "0")
            unique_vals.append((aval, bval))
            if x % 7 == 6:
                # this 2x2 block will be split across bytes, so add an extra coordinate pair with the adjacent byte and high 3 bits = 4
                bval = "%100" + bin(byte+1)[2:].rjust(5, "0") + ";"
                unique_vals.append((aval, bval))
        else:
            # high 3 bits are 5-7 or 4, low 5 bits are 0-39
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
