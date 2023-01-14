#!/usr/bin/bash -x

ZMK_DIR="/home/data/programming/zmk"
CONFIG_DIR="/home/data/programming/keyboards/zmk-corne-aurora/"
OUTPUT_DIR="$CONFIG_DIR/output"
WEST_OPTS="$@"

# +-------------------------+
# | AUTOMATE CONFIG OPTIONS |
# +-------------------------+

cd "$CONFIG_DIR"

# update maximum combos per key
count=$( \
    tail -n +10 config/combos.dtsi | \
    grep -Eo '[LR][TMBH][0-9]' | \
    sort | uniq -c | sort -nr | \
    awk 'NR==1{print $1}' \
)
sed -Ei "/CONFIG_ZMK_COMBO_MAX_COMBOS_PER_KEY/s/=.+/=$count/" config/*.conf
echo "Setting MAX_COMBOS_PER_KEY to $count"

# update maximum keys per combo
count=$( \
    tail -n +10 config/combos.dtsi | \
    grep -o -n '[LR][TMBH][0-9]' | \
    cut -d : -f 1 | uniq -c | sort -nr | \
    awk 'NR==1{print $1}' \
)
sed -Ei "/CONFIG_ZMK_COMBO_MAX_KEYS_PER_COMBO/s/=.+/=$count/" config/*.conf
echo "Setting MAX_KEYS_PER_COMBO to $count"

# +--------------------+
# | BUILD THE FIRMWARE |
# +--------------------+

# usage: compile_board [board] [bin|uf2]
compile_board () {
    echo -e "\n$(tput setaf 4)Building $1$(tput sgr0)"
    west build -d build/$2 -b $1 ${WEST_OPTS} -- -DSHIELD=$2 -DZMK_CONFIG="$CONFIG_DIR/config" -Wno-dev
    if [[ $? -eq 0 ]]
    then
        echo "$(tput setaf 4)Success: $2 done$(tput sgr0)"
        OUTPUT="$OUTPUT_DIR/$3-zmk.$4"
        [[ -f $OUTPUT ]] && [[ ! -L $OUTPUT ]] && mv "$OUTPUT" "$OUTPUT".bak
        cp "$ZMK_DIR/app/build/$2/zephyr/zmk.$4" "$OUTPUT"
    else
        echo "$(tput setaf 1)Error: $2$ failed$(tput sgr0)"
    fi
}

cd "$ZMK_DIR/app"
compile_board nice_nano_v2 splitkb_aurora_corne_left corne_left uf2
compile_board nice_nano_v2 splitkb_aurora_corne_right corne_right uf2
#
#compile_board nice_nano_v2 splitkb_aurora_sweep_left  isa_left uf2
#compile_board nice_nano_v2 splitkb_aurora_sweep_right isa_right uf2

# compile_board nice_nano_v2 cradio_left  sweep_left uf2
# compile_board nice_nano_v2 cradio_right sweep_right uf2
