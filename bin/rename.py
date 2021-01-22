#!/usr/bin/env python3

import fileinput
import glob
import subprocess
import sys

def replace_string_in_file(filename, old_string, new_string):
    for line in fileinput.input(glob.glob(filename), inplace=True):
        print(line.replace(old_string, new_string), end='')

def rename_files_in_directory(dirname, old_filename, new_filename):
    for filename in glob.glob(f'{dirname}/{old_filename}*'):
        subprocess.run(['git', 'mv', filename, filename.replace(old_filename, new_filename)])

def rename_one_file_in_directory(dirname, old_filename, new_filename):
    for filename in glob.glob(f'{dirname}/{old_filename}'):
        subprocess.run(['git', 'mv', f'{dirname}/{old_filename}', f'{dirname}/{new_filename}'])

def rename_inside_disk_image(filename, old_name, new_name):
    rt = subprocess.run(['cadius', 'CATALOG', filename], stdout=subprocess.PIPE, text=True)
    if not [line for line in rt.stdout.split('\n') if line == f'/{old_name}/']:
        return
    subprocess.run(['cadius', 'RENAMEFILE', filename, f'/{old_name}/{old_name}', new_name], stdout=subprocess.PIPE, text=True)
    subprocess.run(['cadius', 'RENAMEVOLUME', filename, new_name], stdout=subprocess.PIPE, text=True)

def rename(old_game_name, new_game_name):
    print(old_game_name)
    for filename in glob.glob('res/dsk/*'):
        rename_inside_disk_image(filename, old_game_name, new_game_name)

    for filename in ('res/GAMES.CONF',
                     f'res/ATTRACT/{old_game_name}',
                     'res/SS/*'):
        replace_string_in_file(filename, old_game_name, new_game_name)

    for dirname in ('res/DEMO',):
        rename_one_file_in_directory(dirname, old_game_name, new_game_name)

    replace_string_in_file('res/DEMO/_FileInformation.txt', f'{old_game_name}=', f'{new_game_name}=')

    for filename in ('res/ATTRACT.CONF',):
        replace_string_in_file(filename, f'{old_game_name}=0', f'{new_game_name}=0')

    replace_string_in_file('src/prelaunch/*', f'build/PRELAUNCH/{old_game_name}', f'build/PRELAUNCH/{new_game_name}')

    for dirname in ('res/ACTION.DHGR',
                    'res/ACTION.DHGR.UNCOMPRESSED',
                    'res/ACTION.GR',
                    'res/ACTION.HGR',
                    'res/ACTION.HGR.UNCOMPRESSED',
                    'res/ARTWORK.SHR',
                    'res/ARTWORK.SHR.UNCOMPRESSED',
                    'res/ATTRACT',
                    'res/GAMEHELP',
                    'res/TITLE.ANIMATED',
                    'res/TITLE.DHGR',
                    'res/TITLE.HGR'):
        rename_files_in_directory(dirname, old_game_name, new_game_name)

def driver():
    rename("SLICKS", "S8")
    rename("CIDER.SPIDER", "AC")
    rename("ARCADE.BT.CAMP", "AB")
    rename("ARDY.AARDVARK", "AA")
    rename("ASTEROID.BLASTR", "AS")
    rename("BCS.QUEST", "BQ")
    rename("BEACH.HEAD.II", "B2")
    rename("BEACH.HEAD", "B1")
    rename("BEYOND.WOLFEN", "BW")
    rename("BUDGETRILOGY", "BT")
    rename("BLOCKCHAIN", "BC")
    rename("BOP.N.WRESTLE", "BN")
    rename("BOUNCING.KMNGAS", "BK")
    rename("BRAINTEASERBLVD", "BB")
    rename("BUCK.ROGERS", "BR")
    rename("BURGERTIME", "BU")
    rename("CALI.GAMES", "CA")
    rename("CANNONBALL.BLTZ", "CB")
    rename("CAPTN.GOODNIGHT", "CG")
    rename("SMURFEN", "CS")
    rename("WOLFEN84", "CW")
    rename("CAVRNS.CALLISTO", "CC")
    rename("CHAMP.LODERUN", "CL")
    rename("COPTS.ROBBERS", "CR")
    rename("D.GENERATION", "DG")
    rename("DARKSTAR.UNHNGD", "DU")
    rename("DAVIDS.MAGIC", "DM")
    rename("EGGS.IT", "EI")
    rename("FUJI.SPEED.WAY", "FC")
    rename("IMPOSSIBLE.MISS", "I1")
    rename("IMPOSSIBLE.M.II", "I2")
    rename("INTL.GRAN.PRIX", "IG")
    rename("EAGLES.NEST", "IE")
    rename("I.O.SILVER", "IO")
    rename("LITTLE.COMP.PPL", "LP")
    rename("LOCK.N.CHASE", "LC")
    rename("MARIO.BROS", "MB")
    rename("MATTERHORN", "MS")
    rename("MINGS.CHALLENGE", "MI")
    rename("THUNDERHEAD", "MT")
    rename("MONTEZUMA", "MZ")
    rename("MR.COOL", "MC")
    rename("MR.DO", "MD")
    rename("MR.ROBOT", "MR")
    rename("MS.PACMAN", "MP")
    rename("NIGHT.MISSION", "NM")
    rename("NIGHTMARE", "NI")
    rename("ONE.ON.ONE", "OO")
    rename("ORILEYS.MINE", "OM")
    rename("OOTW", "OW")
    rename("PANDORAS.BOX", "PB")
    rename("PHARAOHS.REVNG", "PR")
    rename("PIEMAN", "PM")
    rename("PRINCEUNP", "PP")
    rename("RAID.OVR.MOSCOW", "RM")
    rename("REALM.IMPOSS", "RI")
    rename("SITUATION.CRTCL", "SC")
    rename("SOKO.BAN", "SO")
    rename("SPDWAY.CLASSIC", "SP")
    rename("SPYS.DEMISE", "SD")
    rename("SS.BASEBALL", "SB")
    rename("SS.BASKETBALL", "SK")
    rename("SS.FOOTBALL", "SF")
    rename("SS.SOCCER", "SS")
    rename("SUICIDE", "SU")
    rename("TAG.TEAM", "TT")
    rename("TECHNOCOP", "TC")
    rename("THAROLIAN.TUNLS", "TU")
    rename("ASTEROID.FIELD", "AF")
    rename("SUMMER.EDITION", "SE")
    rename("WINTER.EDITION", "WE")
    rename("LAST.GLADIATOR", "LG")
    rename("SPY.STRIKES.BAK", "S2")
    rename("TRACK.AND.FIELD", "TF")
    rename("TUBEWAY", "TB")
    rename("UP.N.DOWN", "UD")
    rename("ROGER.RABBIT", "RR")
    rename("WINGS.OF.FURY", "WF")
    rename("WORLD.KARATE", "WK")

if __name__ == '__main__':
    driver()
