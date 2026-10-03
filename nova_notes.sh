#!/bin/bash
clear

CYAN='\033[0;36m'
SILVER='\033[0;37m'
RED='\033[0;31m'
NC='\033[0m'

LOCAL_DIR="./Notes_Archive"
mkdir -p "$LOCAL_DIR"

CHOOSE_MODE() {
    clear
    echo "+---------------------------------------+"
    echo " |        NOVASYNC CONNECTION CORE       |"
    echo "+---------------------------------------+"
    echo "  1) Work Offline (Local Storage Mode)"
    echo "  2) Connect to Remote Online Server"
    echo "---------------------------------------"
    read -p " Select Connection Layer [1-2]: " mode_choice
    
    if [ "$mode_choice" = "2" ]; then
        read -p " Enter Server URL (e.g. http://127.0.0.1:3000): " SERVER_IP
        NET_MODE="ONLINE"
    else
        NET_MODE="OFFLINE"
    fi
}

CHOOSE_MODE

while true; do
    clear
    echo -e "${CYAN}+---------------------------------------+"
    echo " |              NOVA_NOTES               |"
    echo " |  Mode: $NET_MODE"
    echo -e "+---------------------------------------+${NC}"
    echo "  1) Create New Note"
    echo "  2) Read Saved Notes"
    echo "  3) Search Keywords (Local Only)"
    echo "  4) Delete All Notes"
    echo "  5) Change Connection Mode / Exit"
    echo "---------------------------------------"
    echo -e "${SILVER}  +---------------------------------------+"
    echo -e "   Made with ${RED}❤️ ${SILVER} by Nova Studios."
    echo -e "  +---------------------------------------+${NC}"
    echo
    read -p " Select Option [1-5]: " choice
    
    case $choice in
        1)
            clear
            read -p " Enter Note Title: " title
            [ -z "$title" ] && continue
            filename=$(echo "$title" | tr ' ' '_')
            read -p " Note Text > " content
            
            if [ "$NET_MODE" = "ONLINE" ]; then
                curl -s -X POST -H "Content-Type: application/json" -d "{\"filename\":\"$filename\",\"title\":\"$title\",\"content\":\"$content\",\"date\":\"$(date)\"}" "$SERVER_IP/api/save" >/dev/null
            else
                cat << NOTE_EOF > "$LOCAL_DIR/$filename.txt"
=========================================
 TITLE: $title
 DATE:  $(date)
=========================================
$content
=========================================
 Made with ❤️ by Nova Studios.
=========================================
NOTE_EOF
            fi
            echo -e "\n  [^+] Note saved successfully!"
            read -p " Press Enter..."
            ;;
        2)
            clear
            if [ "$NET_MODE" = "ONLINE" ]; then
                curl -s "$SERVER_IP/api/notes" | grep -o '"[^"]*"' | tr -d '"' | sed 's/^/   [*] /'
            else
                for file in "$LOCAL_DIR"/*.txt; do [ -f "$file" ] && basename "$file" .txt | sed 's/_/ /g' | sed 's/^/   [*] /'; done
            fi
            echo "---------------------------------------"
            read -p " Type exact note name to open: " read_target
            [ -z "$read_target" ] && continue
            read_file=$(echo "$read_target" | tr ' ' '_')
            clear
            if [ "$NET_MODE" = "ONLINE" ]; then
                curl -s -X POST -H "Content-Type: application/json" -d "{\"filename\":\"$read_file\"}" "$SERVER_IP/api/read"
            else
                cat "$LOCAL_DIR/$read_file.txt" 2>/dev/null || echo "[X] Note not found."
            fi
            echo
            read -p " Press Enter to continue..."
            ;;
        3)
            clear
            if [ "$NET_MODE" = "ONLINE" ]; then echo "Online indexing handled via repository hubs."; read -p "Press Enter..."; continue; fi
            read -p " Enter search term: " keyword
            grep -il "$keyword" "$LOCAL_DIR"/*.txt | while read -r match; do basename "$match" .txt | sed 's/_/ /g' | sed 's/^/   [+] MATCH: /'; done
            read -p " Press Enter..."
            ;;
        4)
            clear
            read -p " ⚠️ Wipe all notes? (Y/N): " confirm
            if [ "$confirm" = "Y" ] || [ "$confirm" = "y" ]; then
                if [ "$NET_MODE" = "ONLINE" ]; then curl -s -X POST "$SERVER_IP/api/wipe" >/dev/null; else rm -f "$LOCAL_DIR"/*.txt; fi
                echo " [^+] Done."
                read -p " Press Enter..."
            fi
            ;;
        5)
            CHOOSE_MODE
            ;;
    esac
done
