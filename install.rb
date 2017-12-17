#!/usr/bin/env ruby
require './lib/cmn-lib.rb'
require './lib/mbr.rb'
require './lib/efi.rb'

if ENV['USER'] != "root"
    colorfull("ÉRREUR: VOUS DEVEZ LANCER CE SCRIPT EN TANT QUE ROOT!")
    quit(1)
end

clear()
puts "════════════════════════════════════════"
puts "Installer en mode EFI ?"
efi = input()

if efi == "oui"
    colorfull("Oups !")    
    puts "════════════════════════════════════════"
    sleep 1
    clear()
    colorfull("Cette fontionnalité n'est pas encore implémenté ¯\\_(ツ)_/¯")
    quit(1)

elsif efi == "non" or efi == "n"    
    $disk_process = yesno("Faut il Partitioner et formater le disque ?\n"\
                          "Dans le cas échéant assurer vous de monter les\n"\
                          "partitions dans /mnt/new-sys/")
    if $disk_process == 1
        disk()
    else
        $drive = dialog("Veuillez préciser le disque monté\nExemple: '/dev/sda'", 1)
    end
    debootstrap()
else
    clear()
    colorfull("ÉRREUR: LA RÉPONSE FOURNI EST DIFFÉRENTE DE OUI OU NON")
    quit(1)
end
quit(0)
