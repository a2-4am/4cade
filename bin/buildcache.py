#!/usr/bin/env python3

from collections import OrderedDict
from pprint import pprint
from string import ascii_lowercase
from sys import stdin

def score(inputbuffer, displayname):
    if len(inputbuffer) > len(displayname):
        return 0, False
    likely = True
    startat = 0
    score = 0
    for c in inputbuffer:
        x = 10
        y = displayname[startat:].find(c)
        if y < 0:
            return 0, False
        if y == 0:
            x = 80
        elif (startat > 0) and (displayname[startat+y-1] == " "):
            x = 90
        else:
            likely = False
        score += x
        startat += y + 1
    score = int(score/len(displayname) + (score/len(inputbuffer)) + 0.99)/2
    if (inputbuffer[0] == displayname[0]) and (score < 85):
        score += 15
    return score, likely

def best(keys, games):
    gameindex = 0
    bestscore = -1
    bestindex = -1
    bestlikely = False
    for game in games:
        if game.replace(' ', '').startswith(keys):
            return gameindex
        gamescore, likely = score(keys, game)
        if (gamescore > bestscore):
            bestscore = gamescore
            bestindex = gameindex
            bestlikely = likely
        gameindex += 1
    if not bestlikely:
        return -1
    return bestindex

def main():
    games = [line.strip().lower() for line in stdin]
    cache = OrderedDict()
    for a in ascii_lowercase:
        index1 = best(a, games)
        if index1 < 0: continue
        cache[a] = OrderedDict()
        cache[a][" "] = index1
        for b in ascii_lowercase:
            index2 = best(a+b, games)
            if index2 < 0: continue
            cache[a][b] = OrderedDict()
            if index2 != index1:
                cache[a][b][" "] = index2
            for c in ascii_lowercase:
                index3 = best(a+b+c, games)
                if index3 < 0: continue
                cache[a][b][c] = OrderedDict()
                if index3 != index2:
                    cache[a][b][c][" "] = index3
                for d in ascii_lowercase:
                    index4 = best(a+b+c+d, games)
                    if index4 < 0: continue
                    if index4 != index3:
                        cache[a][b][c][d] = index4
                if not cache[a][b][c]:
                    del cache[a][b][c]
            if not cache[a][b]:
                del cache[a][b]
        if not cache[a]:
            del cache[a]

    print('*=$A000')
    for a in cache:
        print(f'         !text "{a}"')
        if type(cache[a]) == int:
            print(f'         !word {cache[a]}')
        else:
            print(f'         !word _{a}')
    print('         !byte 0')

    for a in cache:
        if type(cache[a]) == int: continue
        print(f'_{a}')
        for b in cache[a]:
            print(f'         !text "{b}"')
            if type(cache[a][b]) == int:
                print(f'         !word {cache[a][b]}')
            else:
                print(f'         !word _{a}{b}')
        print('         !byte 0')

    for a in cache:
        if type(cache[a]) == int: continue
        for b in cache[a]:
            if type(cache[a][b]) == int: continue
            print(f'_{a}{b}')
            for c in cache[a][b]:
                print(f'         !text "{c}"')
                if type(cache[a][b][c]) == int:
                    print(f'         !word {cache[a][b][c]}')
                else:
                    print(f'         !word _{a}{b}{c}')
            print('         !byte 0')

    for a in cache:
        if type(cache[a]) == int: continue
        for b in cache[a]:
            if type(cache[a][b]) == int: continue
            for c in cache[a][b]:
                if type(cache[a][b][c]) == int: continue
                print(f'_{a}{b}{c}')
                for d in cache[a][b][c]:
                    print(f'         !text "{d}"')
                    print(f'         !word {cache[a][b][c][d]}')
                print('         !byte 0')

if __name__ == '__main__':
    main()
