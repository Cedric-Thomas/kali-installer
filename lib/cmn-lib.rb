# Common Lib Install Script
def clear()
    system "clear"
    print "\e[97m"
end

def input()
    input = gets.downcase.delete!("\n")
    return input
end

def yesno(text)
    puts text
    answer = input()
    if answer == "oui" or answer == "o"
        return 1
    elsif answer == "non" or answer == "n"
        return 0
    else
        return -1
    end
end

def dialog(text, var)
    if var == 0 or var == -1
        return nil    
    end
    puts text
    return input()
end

def colorfull(input)
    length = input.length
    for i in 0..length-1
        color = 31 + rand(15)
        if color > 37
            color+=52     
        end
        print "\e[#{color}m#{input[i]}"   
    end
    print "\e[97m\n"
    STDOUT.flush
end

def quit(error_code)
    print "\e[39m"
    exit error_code
end
