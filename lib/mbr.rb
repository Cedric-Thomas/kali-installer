# MBR INSTALLATION SCRIPT
# jetring make git
$info_part = 0

def format(prt, prt_name)
    if prt != nil
        if prt_name == "swap"
            puts("Tiens Une Partition Swap Savage !!")
            if yesno("Exécuter mkswap #{prt} ?") == 1
                system("wipe -fa #{prt} > /dev/null 2>&1")
                system("mkswap #{prt} > /dev/null 2>&1")            
            end
        else      
            if $info_part == 0
                puts "═Info═════════════════════════════════════════════"
                colorfull("Vôtre réponse sera précédé du préfix 'mkfs.'\n"\
                          "Ainsi pour formater en ext4 écriver 'ext4'.\n"\
                          "Vous pouvez ainsi ajouter des arguments.\n"\
                          "Exemple: la réponse 'jfs -q' produira:\n"\
                          "La commande suivante 'mkfs.jfs -q #{prt}'")
                puts "══════════════════════════════════════════════════"
                puts " "                
            $info_part = 1
            end
            puts("Veuillez spécifier le type pour formater la partition #{prt_name}\n")  
            type = input()
            command = "mkfs." + type + " " + prt
            puts "La commande exécutée sera donc #{command}"
            if yesno("Ceci est-il correct ?") == 1
                system("wipefs -fa #{prt} > /dev/null 2>&1")                
                system(command + " > /dev/null 2>&1")
            end
        end    
    end
end

def mount(prt, mountpoint)
    if prt != nil    
        if mountpoint == "swap"
            system("swapon #{prt} > /dev/null 2>&1")
            return
        elsif mountpoint == "chroot"
            
        elsif File.directory?(mountpoint) == false
            system("mkdir #{mountpoint} > /dev/null 2>&1")
        end
        system("mount #{prt} #{mountpoint} > /dev/null 2>&1")
    end
end

def disk()
    colorfull(`lsblk`)
    $drive = dialog("Selectionner un disque d'installation:", 1)
    if yesno("Effacer le disque ?") == 1
        system("dd if=/dev/zero of=#{$drive} bs=512 count=1 > /dev/null 2>&1")
    end
    system("cfdisk #{$drive}")
    clear()
    colorfull(`lsblk #{$drive}`)
    boot = dialog("Veuillez spécifer la partition:", yesno("Utiliser une partition boot séparé ?"))
    home = dialog("Veuillez spécifer la partition:", yesno("Utiliser une partition home séparé ?"))
    swap = dialog("Veuillez spécifer la partition:", yesno("Utiliser une partition de swap ?"))
    puts "════════════════════════════════════════"
    puts "Nous allons maintenant configurer la partition racine."
    root = dialog("Veuillez spécifer la partition:", 1)
    clear()
    puts "══RÉSUMÉ════════════════════════════════"
    if boot != nil    
        colorfull("#{boot} --- /boot")
    end
    colorfull("#{root} --- /")
    if home != nil
        colorfull("#{home} --- /home")
    end
    if swap != nil
        colorfull("#{swap} --- [SWAP]")    
    end
    puts "════════════════════════════════════════"
    if yesno("Ceci est il correct ?") != 1
        clear()       
        colorfull("Bravo, ça ne sait même pas taper correctement sur un clavier.\nRelancer le programme s'il vous plait !")
        quit(1)    
    end
    clear()
    if yesno("Faut-il formater les partitions ?") == 1
        format(root,"root")
        format(boot,"boot")
        format(home,"home")
        format(swap,"swap")
    end
    if yesno("Faut-il monter les partitions ?") == 1
        mount(root,"/mnt/new-sys")
        mount(boot,"/mnt/new-sys/boot")
        mount(home,"/mnt/new-sys/home")
        mount(swap,"swap")
    end
end

def debootstrap()
    colorfull(`lsblk #{$drive}`)
    arch = "amd64"
    incl = "locales,console-data,console-setup,vim,sudo"
    mirror = "https://fr.mirror.babylon.network/kali"
    options = ""
    colorfull("debootstrap --arch=#{arch} --include=#{incl} #{options} kali-rolling /mnt/new-sys #{mirror}\n")
    if yesno("Executer deboostrap avec ces arguments ?\n"\
             "Si vous ne savez pas, choisisez oui") == 0
        loop do
            clear()        
            arch = dialog("Spécifiez l'architecture --arch=\n[default = amd64]", 1)
            incl = dialog("Spécifiez les packets à inclure --include=\n[default = locales,console-data,console-setup,vim,sudo]", 1)
            options = dialog("Spécifiez les options suplémentaire pour debootstrap\n[default = ]\nExemple: --variant=minbase", 1)
            mirror = dialog("Spécifiez le mirroir à utiliser\n[default = https://fr.mirror.babylon.network/kali]", 1)
            colorfull("debootstrap --arch=#{arch} --include=#{incl} #{options} kali-rolling /mnt/new-sys #{mirror}") 
            if yesno("Cela vous convient il ?") == 1
                break
            end
        end
    end

    if File.exist?("/usr/share/debootstrap/scripts/kali-rolling") == false
        system("git clone git://git.kali.org/packages/debootstrap.git;cp debootstrap/scripts/kali-rolling /usr/share/debootstrap/scripts/;rm -rf debootstrap")
    end
    if File.exist?("/usr/share/keyrings/kali-archive-keyring.gpg") == false
        system("git clone git://git.kali.org/packages/kali-archive-keyring.git;cd kali-archive-keyring/;make;make install;cd ..;rm -rf kali-archive-keyring")
    end
    system("debootstrap --arch=#{arch} --include=#{incl} #{options} kali-rolling /mnt/new-sys #{mirror}")
end
